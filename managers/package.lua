local core = require 'core'
local common = require 'core.common'
local net = require 'plugins.lxpm.net'
local util = require 'plugins.lxpm.util'
local pmconfig = require 'plugins.lxpm.config'

local m = {}

---@param url string
function m.load_and_run_installer(url)
  LXPM:log("Loading installer from the internet...")
  net.load(url, function(ok, result, err)
    if not ok then
      return LXPM:error("An error has ocorred: " .. err)
    end
    local lload = rawget(_G, "loadstring") or rawget(_G, "load")
    LXPM:log("Running installer...")
    local installer
    installer, err = lload(result)
    if installer == nil then
      return LXPM:error("This installer has an error: " .. err)
    end
    core.add_thread(installer)
  end)
end

function m.load_list()
  LXPM:log("Loading package list...")
  net.load(pmconfig.db.packages, function(ok, result, err)
    local packages = {}
    if ok then
      packages = util.parse_data(result, pmconfig.patterns.packages)
    else
      LXPM:error("Error loading package list: " .. err)
    end
    core.command_view:enter(
      "Select installer or put direct URL",
      function(url, item)
        if url:match("://") and not url:match("http[s]?://") then
          LXPM:error("This URL is invalid! Only HTTP[s] are supported")
          return
        end
        if not url:match("http[s]?://") then
          local name = util.split(item.text, " ")[1]
          url = pmconfig.base_url.packages .. packages[name][2]
        end
        m.load_and_run_installer(url)
      end,
      function(text)
        local list = {}
        for i, pack in ipairs(packages) do
          list[i] = pack[1].." - "..pack[3]
        end
        list = common.fuzzy_match(list, text)
        if text == "" then table.sort(list) end
        return list
      end
    )
  end)
end

return m
