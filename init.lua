-- mod-version:2

require 'plugins.lite-xl-pm.configure'
local core = require 'core'
local command = require 'core.command'
local common = require 'core.common'
local system = require 'system'
local util = require 'plugins.lite-xl-pm.util'
local net = require 'plugins.lite-xl-pm.net'

-- URLs
local PLUGIN_BASE_URL = "https://github.com/lite-xl/lite-xl-plugins/blob/master/"
local PLUGIN_DB_URL = "https://raw.githubusercontent.com/lite-xl/lite-xl-plugins/master/README.md"
local COLORS_BASE_URL = "https://github.com/lite-xl/lite-xl-colors/blob/master/"
local COLORS_DB_URL = "https://raw.githubusercontent.com/lite-xl/lite-xl-colors/master/README.md"

-- Patterns
local PLUGIN_PATTERN = "%[`([%w|%S]+)%`]%((%S+)%)[ ]+|[ ]+([%w|%S| ]*)|"
local COLORS_PATTERN = "%[`([%w|%S]+)%`]%((%S+)%)[ ]+|"

---@param folder string
---@param name string
---@param path string
local function download_and_load(folder, name, path)
  local url = path
  if not url:find("://") then
    url = ((folder == 'plugins' and PLUGIN_BASE_URL) or COLORS_BASE_URL) .. path
  end
  net.download(
    ("%s/%s/%s.lua"):format(USERDIR, folder, name), url,
    function(ok, out)
      if not ok then
        return core.log("[PluginManager] Error running curl: "..out)
      elseif folder == "plugins" then
        core.load_plugins()
        core.log("[PluginManager] Plugin '"..name.."' installed and loaded")
      else
        core.reload_module("colors."..name)
        core.log("[PluginManager] Theme '"..name.."' installed and loaded")
      end
    end
  )
end

---@param itype "theme"|"plugin"
local function install(itype)
  local url = PLUGIN_DB_URL
  if itype == "theme" then
    url = COLORS_DB_URL
  end
  net.load(url, function(ok, out)
  if not ok then
    return core.log("[PluginManager] Error running curl: " .. out)
  elseif out == "" then
    return core.log("[PluginManager] No data received, It can be a network problem!")
  end
  local pattern = (itype == 'plugin' and PLUGIN_PATTERN) or COLORS_PATTERN
  local list, lsize = util.parse_data(out, pattern)
  coroutine.yield(2)
  if lsize == 0 then
    return core.log("[PluginManager] The list is empty, It can be a bug!")
  end
  core.command_view:enter(
    "Install "..itype,
    function(text, item)
      local text = (item and item.text or text)
      local name = text:sub(1, (text:find(" ") or #text+1)-1)
      core.log("[PluginManager] Installing "..itype.." '"..name.."'...")
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
      return common.fuzzy_match(items, text)
    end)
  end) -- End thread creation
end

---@param rtype "theme"|"plugin"
local function uninstall(rtype)
  local folder = USERDIR .. (rtype == 'theme' and "/colors/") or "/plugins/"
  local files = system.list_dir(folder)
  for i, file in ipairs(files) do
    local info = system.get_file_info(folder .. file)
    if info.type == "dir" then
      table.remove(files, i)
      goto skip
    end
    files[i] = file:gsub("%.lua$", "")
    ::skip::
  end
  if #files == 0 then
    return core.log("[PluginManager] You dont have " .. rtype .. "'s installed!")
  end
  table.sort(files)
  core.command_view:enter(
    "Uninstall "..rtype,
    function(text, item)
      local name = (item and item.text) or text
      local ok, err = os.remove(folder .. name .. ".lua")
      if ok then
        core.log("[PluginManager] Ok "..rtype.." '"..name.."' removed! Restart your editor.")
      else
        core.log("[PluginManager] '"..name.."' not remove due to an error: "..err)
      end
    end,
    function(text)
      return common.fuzzy_match(files, text)
    end)
end

command.add(nil, {
    ["PluginManager:install-plugin"] = function()
      core.log("[PluginManager] Loading plugin list...")
      core.add_thread(install, nil, "plugin")
    end,
    ["PluginManager:install-theme"] = function()
      core.log("[PluginManager] Loading theme list...")
      core.add_thread(install, nil, "theme")
    end,
    ["PluginManager:uninstall-plugin"] = function()
      core.add_thread(uninstall, nil, "plugin")
    end,
    ["PluginManager:uninstall-theme"] = function()
      core.add_thread(uninstall, nil, "theme")
    end
  }
)

