-- mod-version:2

require 'plugins.lite-xl-pm.replacefunctions'
local core = require 'core'
local command = require 'core.command'
local common = require 'core.common'
local keymap = require 'core.keymap'
local system = require 'system'
local pmconfig = require 'plugins.lite-xl-pm.config'
local util = require 'plugins.lite-xl-pm.util'
local net = require 'plugins.lite-xl-pm.net'
local logger = require 'plugins.lite-xl-pm.logger'

local pluginmanager = logger:new("[PluginManager]")

---@param folder string
---@param name string
---@param path string
local function download_and_load(folder, name, path)
  local url = path
  if not url:find("://") then
    local base = (folder == 'plugins' and pmconfig.base_url.plugins)
                 or pmconfig.base_url.themes
    url = base .. path
  end
  net.download(
    USERDIR.."/"..folder.."/"..name..".lua", url,
    function(ok, err)
      if not ok then
        return pluginmanager:error("Error running curl: "..err)
      elseif folder == "plugins" then
        core.load_plugins()
        pluginmanager:log("Plugin '"..name.."' installed and loaded")
      else
        core.reload_module("colors."..name)
        pluginmanager:log("Theme '"..name.."' installed and loaded")
      end
    end
  )
end

---@param itype "theme"|"plugin"
local function install(itype)
  pluginmanager:log("Loading " .. itype .. " list...")
  local url = pmconfig.db.plugins
  if itype == "theme" then
    url = pmconfig.db.themes
  end
  net.load(
    url,
    function(ok, result)
      if not ok then
        return pluginmanager:error("Error running curl: " .. result)
      elseif result == "" or result == nil then
        return pluginmanager:error(
          "No data received, It can be a network problem!"
        )
      end
      local pattern = (itype == 'plugin' and pmconfig.patterns.plugins)
                      or pmconfig.patterns.themes
      local list, lsize = util.parse_data(result, pattern)
      coroutine.yield(0.1)
      if lsize == 0 then
        return pluginmanager:error("The list is empty, It can be a bug!")
      end
      core.command_view:enter(
        "Install "..itype,
        function(text, item)
          local name = util.split(item and item.text or text)[1]
          pluginmanager:log("Installing "..itype.." '"..name.."'...")
          local folder = (itype == 'plugin' and "plugins") or "colors"
          core.add_thread(download_and_load, nil, folder, name, list[name].path)
        end,
        function(text)
          local items = {}
          for name, p in pairs(list) do
            table.insert(
              items,
              (itype == 'plugin' and name.." - "..p.description) or name
            )
          end
          local result = common.fuzzy_match(items, text)
          table.sort(result)
          return result
        end
      )
    end
  )
end

---@param rtype "theme"|"plugin"
local function uninstall(rtype)
  local folder = USERDIR .. ((rtype == 'theme' and "/colors/") or "/plugins/")
  local files = system.list_dir(folder)
  local list = {}
  for _, file in pairs(files) do
    local info = system.get_file_info(folder .. file)
    if info.type ~= "dir" then
      local name = file:gsub("%.lua$", "")
      table.insert(list, name)
    end
  end
  if #list == 0 then
    return pluginmanager:log("You dont have " .. rtype .. "'s installed!")
  end
  core.command_view:enter(
    "Uninstall "..rtype,
    function(text, item)
      local name = (item and item.text) or text
      local ok, err = os.remove(folder .. name .. ".lua")
      if ok then
        pluginmanager:log(
          "Ok "..rtype.." '"..name.."' removed! Restart your editor."
        )
      else
        pluginmanager:error("'"..name.."' not remove due to an error: "..err)
      end
    end,
    function(text)
      local result = common.fuzzy_match(list, text)
      table.sort(result)
      return result
    end)
end

local function run_package_installer()
  core.command_view:enter(
    "Direct package installer URL",
    function(url)
      if not url:match("http[s]?://") then
        return pluginmanager:error(
          "This URL is invalid! Only HTTP and HTTPS are supported"
        )
      end
      pluginmanager:log("Loading the installer from the internet...")
      net.load(
        url,
        function(ok, result)
          if not ok then
            return pluginmanager:error("An error has ocorred: " .. result)
          end
          local lload = rawget(_G, "loadstring") or rawget(_G, "load")
          pluginmanager:log("Running installer...")
          local installer, err = lload(result)
          if installer == nil then
            return pluginmanager:error(
              "The returned function is empty, I have an error: " .. err
            )
          end
          core.add_thread(installer)
        end
      )
    end
  )
end

local function install_menu()
  core.command_view:enter(
    "Install",
    function(option, item)
      option = option or item.text
      if option == "Plugin" then
        core.add_thread(install, nil, "plugin")
      elseif option == "Theme" then
        core.add_thread(install, nil, "theme")
      elseif option == "Package" then
        core.add_thread(run_package_installer)
      end
    end,
    function(text)
      local options = { "Package", "Plugin", "Theme" }
      return common.fuzzy_match(options, text)
    end
  )
end

local function uninstall_menu()
  core.command_view:enter(
    "Uninstall",
    function(option, item)
      option = option or item.text
      if option == "Plugin" then
        core.add_thread(uninstall, nil, "plugin")
      elseif option == "Theme" then
        core.add_thread(uninstall, nil, "theme")
      end
    end,
    function(text)
      local options = { "Plugin", "Theme" }
      return common.fuzzy_match(options, text)
    end
  )
end

command.add(nil, {
  ["PluginManager:install"] = install_menu,
  ["PluginManager:uninstall"] = uninstall_menu
})

keymap.add {
  ["ctrl+shift+i"] = "PluginManager:install",
  ["ctrl+shift+u"] = "PluginManager:uninstall"
}
