-- mod-version:2

require 'configure'
local core = require 'core'
local config = require 'core.config'
local command = require 'core.command'
local common = require 'core.common'
local process = require 'process'
local util = require 'util'

local PLUGIN_BASE_URL = "https://github.com/lite-xl/lite-xl-plugins/blob/master/"
local PLUGIN_DB_URL = "https://raw.githubusercontent.com/lite-xl/lite-xl-plugins/master/README.md"
local COLORS_BASE_URL = "https://github.com/lite-xl/lite-xl-colors/blob/master/"
local COLORS_DB_URL = "https://raw.githubusercontent.com/lite-xl/lite-xl-colors/master/README.md"


---@param folder string
---@param name string
---@param path string
local function download_and_load(folder, name, path)
  local url = path
  if not url:find("://") then
    if folder == "plugins" then
      url = PLUGIN_BASE_URL .. path
    else
      url = COLORS_BASE_URL .. path
    end
  end
  util.run(
    { "curl", "-sL", url, "-o", ("%s/%s/%s.lua"):format(USERDIR, folder, name) },
    function(ok, out)
      if not ok then
        core.log("[PluginManager] Error running curl: "..out)
        return
      end
      if folder == "plugins" then
        config.plugins[name] = require('plugins.'..name)
        core.log("[PluginManager] Plugin '"..name.."' installed and loaded")
      else
        core.reload_module("colors."..name)
        core.log("[PluginManager] Theme '"..name.."' installed and loaded")
      end
    end
  )
end

---@param itype string
local function install(itype)
  local url = PLUGIN_DB_URL
  if itype == "theme" then
    url = COLORS_DB_URL
  end
  core.add_thread(util.run, nil, { "curl", "-sL", url }, function(ok, out)
  if not ok then
    return core.log("[PluginManager] Error running curl: " .. out)
  elseif out == "" then
    return core.log("[PluginManager] No data received, It can be a network problem!")
  end
  local list, lsize
  if itype == "plugin" then
    list, lsize = util.get_plugins(out)
  else
    list, lsize = util.get_colors(out)
  end
  coroutine.yield(2)
  if lsize == 0 then
    return core.log("[PluginManager] The list is empty, It can be a bug!")
  else
    core.command_view:enter(
      "Install "..itype,
      function(text, item)
        local text = item and item.text or text
        if text == "" then
          return core.log("[PluginManager] Operation cancelled!")
        end
        local space = text:find(" ") or #text+1
        local name = text:sub(1, space-1)
        core.log("[PluginManager] Installing "..itype.." '"..name.."'...")
        local folder = "plugins"
        if itype == "theme" then
          folder = "colors"
        end
        core.add_thread(download_and_load, nil, folder, name, list[name].path)
      end,
      function(text)
        local items = {}
        for name, p in pairs(list) do
          if itype == "plugin" then
            table.insert(items, name .. " - " .. p.description)
          else
            table.insert(items, name)
          end
        end
        return common.fuzzy_match(items, text)
      end
    )
  end
  end) -- End thread creation
end

command.add(nil, {
    ["PluginManager:plugin-install"] = function()
      core.log("[PluginManager] Loading plugin list...")
      core.add_thread(install, nil, "plugin")
    end,
    ["PluginManager:theme-install"] = function()
      core.log("[PluginManager] Loading theme list...")
      core.add_thread(install, nil, "theme")
    end
  }
)

