-- mod-version:2

local core = require 'core'
local command = require 'core.command'
local common = require 'core.common'
local process = require 'process'
local util = require 'util'

local DB_URL = "https://raw.githubusercontent.com/lite-xl/lite-xl-plugins/master/README.md"

local function get_and_show_list()
  local proc = process.start({ "curl", "-sf", DB_URL})
  --- Wait until the program close
  while true do
    if not proc:running() then
      break
    end
    coroutine.yield(2)
  end
  core.log("Lista obtida")
  local data = proc:read_stdout()
  local plugins = util.get_plugins(data)
  coroutine.yield(1)
  core.command_view:enter(
    "Install Plugin",
    function(text, item)
      core.log("Você escolheu: " .. item.text)
    end,
    function(text)
      local items = {}
      for _, p in ipairs(plugins) do
        table.insert(items, p.name .. " - " .. p.description)
      end
      return common.fuzzy_match(items, text)
    end
  )
end

local function download_plugin(url)
end

command.add(nil, {
    ["PluginManager:install"] = function()
      core.log("Loading plugin list...")
      core.add_thread(get_and_show_list)
    end
  }
)
