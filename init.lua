-- mod-version:2

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


local function plugin_install()
  local proc = process.start({ "curl", "-sL", PLUGIN_DB_URL})
  --- Wait until the program close
  while true do
    if not proc:running() then
      break
    end
    coroutine.yield(2)
  end
  local data = proc:read_stdout(1 * 1048576) -- 1MiB max
  if data == nil then
    core.log("[PluginManager] No data received, It can be a network problem!")
    return
  end
  local plugins, pcount = util.get_plugins(data)
  coroutine.yield(2)
  if pcount == 0 then
    core.log("[PluginManager] The list is empty, It can be a bug!")
  else
    core.command_view:enter(
      "Install Plugin",
      function(text, item)
        local text = item and item.text or text
        if text == "" then
          core.log("[PluginManager] Operation cancelled!")
          return
        end
        local space = text:find(" ")
        local name = text:sub(1, space-1)
        core.log("[PluginManager] Installing plugin '"..name.."'...")
        local plugin = plugins[name]
        core.add_thread(function()
          local url = plugin.path
          if not url:find("://") then
            url = PLUGIN_BASE_URL .. plugin.path
          end
          local downloader = process.start({
            "curl", "-sL", url, "-o", USERDIR.."/plugins/"..name..".lua"
          })
          while true do
            if not downloader:running() then
              break
            end
            coroutine.yield(2)
          end
          config.plugins[name] = require('plugins.'..name)
          core.log("[PluginManager] Plugin '"..name.."' installed and loaded")
        end)
      end,
      function(text)
        local items = {}
        for name, p in pairs(plugins) do
          table.insert(items, name .. " - " .. p.description)
        end
        return common.fuzzy_match(items, text)
      end
    )
  end
end

local function theme_install()
  local proc = process.start({ "curl", "-sL", COLORS_DB_URL})
  --- Wait until the program close
  while true do
    if not proc:running() then
      break
    end
    coroutine.yield(2)
  end
  local data = proc:read_stdout(1 * 1048576) -- 1MiB max
  if data == nil then
    core.log("[PluginManager] No data received, It can be a network problem!")
    return
  end
  local colors, pcount = util.get_colors(data)
  coroutine.yield(2)
  if pcount == 0 then
    core.log("[PluginManager] The list is empty, It can be a bug!")
  else
    core.command_view:enter(
      "Install Theme",
      function(text, item)
        local name = item and item.text or text
        if name == "" then
          core.log("[PluginManager] Operation cancelled!")
          return
        end
        core.log("[PluginManager] Installing theme '"..name.."'...")
        core.add_thread(function()
          local url = colors[name]
          if not url:find("://") then
            url = COLORS_BASE_URL .. colors[name]
          end
          local downloader = process.start({
            "curl", "-sL", url, "-o", USERDIR.."/colors/"..name..".lua"
          })
          while true do
            if not downloader:running() then
              break
            end
            coroutine.yield(2)
          end
          core.reload_module("colors."..name)
          core.log("[PluginManager] Theme '"..name.."' installed and loaded")
        end)
      end,
      function(text)
        local items = {}
        for name, _ in pairs(colors) do
          table.insert(items, name)
        end
        return common.fuzzy_match(items, text)
      end
    )
  end
end

command.add(nil, {
    ["PluginManager:plugin-install"] = function()
      core.log("[PluginManager] Loading plugin list...")
      core.add_thread(plugin_install)
    end,
    ["PluginManager:theme-install"] = function()
      core.log("[PluginManager] Loading theme list...")
      core.add_thread(theme_install)
    end
  }
)

