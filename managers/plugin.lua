local core = require 'core'
local common = require 'core.common'
local pmconfig = require 'plugins.lxpm.config'
local net = require 'plugins.lxpm.net'
local util = require 'plugins.lxpm.util'
local system = require 'system'

local m = {}

---@param name string
---@param url string
function m.install(name, url)
  LXPM:log("Installing '"..name.."' plugin...")
  net.download(
    USERDIR.."/plugins/"..name..".lua", url,
    function(ok, err)
      if ok then
        LXPM:log("Plugin '"..name.."' installed, reload your editor!")
      else
        LXPM:error("Error running curl: "..err)
      end
    end
  )
end

function m.load_list()
  LXPM:log("Loading plugin list...")
  net.load(
    pmconfig.db.plugins,
    function(ok, result, err)
      if not ok then
        return LXPM:error("Error running curl: " .. err)
      end
      local plugins = util.parse_data(result, pmconfig.patterns.plugins)
      coroutine.yield(0.1)
      if #plugins == 0 then
        return LXPM:error("The list is empty, It can be a bug!")
      end
      core.command_view:enter(
        "Install plugin",
        function(text, item)
          local name = util.split(item and item.text or text)[1]
          local exists, plugin = util.contain(plugins, name)
          if not exists then
            return LXPM:error("Plugin '"..name.."' is not in the list!")
          end
          local url = pmconfig.base_url.plugins .. plugin[2]
          core.add_thread(m.install, nil, name, url)
        end,
        function(text)
          local items = {}
          for _, plugin in ipairs(plugins) do
            if not util.contain(pmconfig.ignore_plugins, plugin[1]) then
              table.insert(items, plugin[1].." - "..util.trim(plugin[3]))
            end
          end
          items = common.fuzzy_match(items, text)
          if text == "" then table.sort(items) end
          return items
        end
      )
    end
  )
end

function m.uninstall()
  local folder = USERDIR .. "/plugins/"
  local files = system.list_dir(folder)
  local list = {}
  for _, file in ipairs(files) do
    local info = system.get_file_info(folder .. file)
    if info.type ~= "dir" then
      local name = file:gsub("%.lua$", "")
      table.insert(list, name)
    end
  end
  if #list == 0 then
    return LXPM:log("You dont have plugins installed!")
  end
  core.command_view:enter(
    "Uninstall plugin",
    function(text, item)
      local name = (item and item.text) or text
      local ok, err = os.remove(folder .. name .. ".lua")
      if ok then
        LXPM:log("Ok plugin '"..name.."' removed! Restart your editor.")
      else
        LXPM:error("'"..name.."' not remove due to an error: "..err)
      end
    end,
    function(text)
      local result = common.fuzzy_match(list, text)
      if text == "" then table.sort(result) end
      return result
    end
  )
end

return m
