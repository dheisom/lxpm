-- mod-version:2

require 'plugins.lxpm.replacefunctions'
local core = require 'core'
local command = require 'core.command'
local common = require 'core.common'
local keymap = require 'core.keymap'
local theme = require 'plugins.lxpm.managers.theme'
local plugin = require 'plugins.lxpm.managers.plugin'
local package = require 'plugins.lxpm.managers.package'
local logger = require 'plugins.lxpm.logger'

rawset(_G, "LXPM", logger:new('[LXPM]'))

local function install_menu()
  core.command_view:enter(
    "Install",
    function(option, item)
      option = ((option ~= "" and option) or item.text):lower()
      if option == "plugin" then
        core.add_thread(plugin.load_list)
      elseif option == "theme" then
        core.add_thread(theme.load_list)
      elseif option == "package" then
        core.add_thread(package.load_list)
      end
    end,
    function(text)
      local options = { "Plugin", "Package", "Theme" }
      return common.fuzzy_match(options, text)
    end
  )
end

local function uninstall_menu()
  core.command_view:enter(
    "Uninstall",
    function(option, item)
      option = ((option ~= "" and option) or item.text):lower()
      if option == "plugin" then
        core.add_thread(plugin.uninstall)
      elseif option == "theme" then
        core.add_thread(theme.uninstall)
      end
    end,
    function(text)
      local options = { "Theme", "Plugin" }
      return common.fuzzy_match(options, text)
    end
  )
end

command.add(nil, {
  ["PluginManager:install"] = install_menu,
  ["PluginManager:uninstall"] = uninstall_menu
})

keymap.add {
  ["ctrl+shift+i"] = "PluginManager:install",
  ["ctrl+shift+u"] = "PluginManager:uninstall"
}
