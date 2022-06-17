-- mod-version:3
-- Author: Dheisom Gomes <https://github.com/dheisom>

local core    = require('core')
local command = require('core.command')
local keymap  = require('core.keymap')
local config  = require('plugins.lxpm.config')
local logger  = require('plugins.lxpm.logger')
local net     = require('plugins.lxpm.net')
local LxpmUI  = require('plugins.lxpm.ui')


local info = logger:new("[LXPM]")

local function update_database()
  info:log("Updating database...")
  local ok, err = net.download(config.database_url, config.local_database)
  if not ok then
    return info:error("Failed to update database: "..err)
  end
  info:log("Database updated!")
end

local lxpm_ui = LxpmUI()

command.add(nil, {
  ["LXPM:Open"] = function()
    local loaded = lxpm_ui:load_database()
    if not loaded then return end
    lxpm_ui:show()
    local node = core.root_view:get_active_node_default()
    for _, view in ipairs(node.views) do
      if view == lxpm_ui then
        node:set_active_view(view)
        return
      end
    end
    node:add_view(lxpm_ui)
  end
})

command.add(nil, {
  ["LXPM:Update Database"] = function() core.add_thread(update_database) end
})

keymap.add { ["ctrl+shift+i"] = "LXPM:Open" }
