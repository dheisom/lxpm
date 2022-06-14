-- mod-version:3
-- Author: Dheisom Gomes <https://github.com/dheisom>

local command = require('core.command')
local keymap = require('core.keymap')

local function open()
end

command.add(nil, { ["LXPM:Open"] = open })

keymap.add { ["ctrl+shift+i"] = "LXPM:Open" }
