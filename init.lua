-- mod-version:2

require 'plugins.lxpm.replacefunctions'
local core = require 'core'
local command = require 'core.command'
local common = require 'core.common'
local keymap = require 'core.keymap'
local system = require 'system'
local pmconfig = require 'plugins.lxpm.config'
local util = require 'plugins.lxpm.util'
local net = require 'plugins.lxpm.net'
local logger = require 'plugins.lxpm.logger'

local lxpm = logger:new("[LXPM]")

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
        return lxpm:error("Error running curl: "..err)
      elseif folder == "plugins" then
        core.load_plugins()
        lxpm:log("Plugin '"..name.."' installed and loaded")
      else
        core.reload_module("colors."..name)
        lxpm:log("Theme '"..name.."' installed and loaded")
      end
    end
  )
end

---@param itype "theme"|"plugin"
local function install(itype)
  lxpm:log("Loading " .. itype .. " list...")
  local url = (itype == "theme" and pmconfig.db.themes)
              or pmconfig.db.plugins
  net.load(
    url,
    function(ok, result)
      if not ok then
        return lxpm:error("Error running curl: " .. result)
      elseif result == "" or result == nil then
        return lxpm:error("No data received, It can be a network problem!")
      end
      local pattern = (itype == "theme" and pmconfig.patterns.themes)
                      or pmconfig.patterns.plugins
      local list, lsize = util.parse_data(result, pattern)
      coroutine.yield(0.1)
      if lsize == 0 then
        return lxpm:error("The list is empty, It can be a bug!")
      end
      core.command_view:enter(
        "Install "..itype,
        function(text, item)
          local name = util.split(item and item.text or text)[1]
          lxpm:log("Installing "..itype.." '"..name.."'...")
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
          items = common.fuzzy_match(items, text)
          table.sort(items)
          return items
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
    return lxpm:log("You dont have " .. rtype .. "'s installed!")
  end
  core.command_view:enter(
    "Uninstall "..rtype,
    function(text, item)
      local name = (item and item.text) or text
      local ok, err = os.remove(folder .. name .. ".lua")
      if ok then
        lxpm:log("Ok "..rtype.." '"..name.."' removed! Restart your editor.")
      else
        lxpm:error("'"..name.."' not remove due to an error: "..err)
      end
    end,
    function(text)
      local result = common.fuzzy_match(list, text)
      table.sort(result)
      return result
    end)
end

local function load_and_run_installer(url)
  lxpm:log("Loading installer from the internet...")
  net.load(
    url,
    function(ok, result)
      if not ok then
        return lxpm:error("An error has ocorred: " .. result)
      end
      local lload = rawget(_G, "loadstring") or rawget(_G, "load")
      lxpm:log("Running installer...")
      local installer, err = lload(result)
      if installer == nil then
        return lxpm:error(
          "The returned function is empty, I have an error: " .. err
        )
      end
      core.add_thread(installer)
    end
  )
end

local function package_installer()
  lxpm:log("Loading package list...")
  net.load(
    pmconfig.db.packages,
    function(ok, result)
      local packages = {}
      if not ok then
        lxpm:error("Error loading package list!")
      else
        packages = util.parse_data(result, pmconfig.patterns.packages)
      end
      core.command_view:enter(
        "Select installer or put direct URL",
        function(url, item)
          if url:match("://") and not url:match("http[s]?://") then
            return lxpm:error(
              "This URL is invalid! Only HTTP and HTTPS are supported"
            )
          end
          if url:match("http[s]?://") then
            load_and_run_installer(url)
          else
            local name = util.split(item.text, " ")[1]
            load_and_run_installer(pmconfig.base_url.packages .. packages[name].path)
          end
        end,
        function(text)
          local list = {}
          for name, p in pairs(packages) do
            table.insert(list, name .. " - " .. p.description)
          end
          list = common.fuzzy_match(list, text)
          table.sort(list)
          return list
        end
      )
    end
  )
end

local function install_menu()
  core.command_view:enter(
    "Install",
    function(option, item)
      option = ((option ~= "" and option) or item.text or ""):lower()
      if option == "plugin" then
        core.add_thread(install, nil, "plugin")
      elseif option == "theme" then
        core.add_thread(install, nil, "theme")
      elseif option == "package" then
        core.add_thread(package_installer)
      end
    end,
    function(text)
      local options = { "Plugin", "Package", "Theme" }
      return common.fuzzy_match(options, text)
    end
  )
end

local function uninstall_menu()
  core.command_view:enter(
    "Uninstall",
    function(option, item)
      option = (option or item.text):lower()
      if option == "plugin" then
        core.add_thread(uninstall, nil, "plugin")
      elseif option == "theme" then
        core.add_thread(uninstall, nil, "theme")
      end
    end,
    function(text)
      local options = { "Theme", "Plugin" }
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
