-- mod-version:2

local core = require 'core'
local command = require 'core.command'
local common = require 'core.common'
local process = require 'process'
local util = require 'util'

local BASE_URL = "https://github.com/lite-xl/lite-xl-plugins/blob/master/"
local DB_URL = "https://raw.githubusercontent.com/lite-xl/lite-xl-plugins/master/README.md"


local function get_and_show_list()
  local proc = process.start({ "curl", "-sL", DB_URL})
  --- Wait until the program close
  while true do
    if not proc:running() then
      break
    end
    coroutine.yield(2)
  end
  local data = proc:read_stdout(1 * 1048576) -- 1MiB max
  local plugins = util.get_plugins(data)
  coroutine.yield(2)
  if unpack(plugins) then
    core.log("Failed to load plugin list!")
  else
    core.command_view:enter(
      "Install Plugin",
      function(text, item)
        local text = item and item.text or text
        if text == "" then
          core.log("Operation cancelled!")
          return
        end
        local space = text:find(" ")
        local name = text:sub(1, space-1)
        core.log("Installing " .. name .. "...")
        local plugin = plugins[name]
        core.add_thread(function()
          local url = plugin.path
          if not url:find("github.com") then
            url = BASE_URL .. plugin.path
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
          core.log("Plugin '"..name.."' installed, reload your editor")
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


command.add(nil, {
    ["PluginManager:install-plugin"] = function()
      core.log("Loading plugin list...")
      core.add_thread(get_and_show_list)
    end
  }
)

