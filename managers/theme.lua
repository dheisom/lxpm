local core = require 'core'
local common = require 'core.common'
local pmconfig = require 'plugins.lxpm.config'
local net = require 'plugins.lxpm.net'
local util = require 'plugins.lxpm.util'
local system = require 'system'

local m = {}

function m.install(name, url)
  LXPM:log("Installing '"..name.."' theme...")
  net.download(
    USERDIR.."/colors/"..name..".lua", url,
    function(ok, err)
      if ok then
        core.reload_module("colors."..name)
        LXPM:log("Theme '"..name.."' installed, and loaded!")
      else
        LXPM:error("Error running curl: "..err)
      end
    end
  )
end

function m.load_list()
  LXPM:log("Loading theme list...")
  net.load(
    pmconfig.db.themes,
    function(ok, result, err)
      if not ok then
        return LXPM:error("Error running curl: " .. err)
      end
      local themes = util.parse_data(result, pmconfig.patterns.themes)
      coroutine.yield(0.1)
      if #themes == 0 then
        return LXPM:error("The list is empty, It can be a bug!")
      end
      core.command_view:enter(
        "Install plugin",
        function(text, item)
          local name = util.split(item and item.text or text)[1]
          local exists, theme = util.contain(themes, name)
          if not exists then
            return LXPM:error("Theme '"..name.."' is not in the list!")
          end
          local url = pmconfig.base_url.themes .. theme[2]
          core.add_thread(m.install, nil, name, url)
        end,
        function(text)
          local items = {}
          for i, theme in ipairs(themes) do
            items[i] = theme[1]
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
  local folder = USERDIR .. "/colors/"
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
    return LXPM:log("You dont have themes installed!")
  end
  core.command_view:enter(
    "Uninstall theme",
    function(text, item)
      local name = (item and item.text) or text
      local ok, err = os.remove(folder .. name .. ".lua")
      if ok then
        LXPM:log("Ok theme '"..name.."' removed!")
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
