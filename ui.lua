local common      = require('core.common')
local config      = require('plugins.lxpm.config')
local json        = require('plugins.lxpm.json')
local logger      = require('plugins.lxpm.logger')
local util        = require('plugins.lxpm.util')
local Widget      = require('widget')
local NoteBook    = require('widget.notebook')
local FoldingBook = require('widget.foldingbook')

local info = logger:new("[LXPM]")

---@class Lxpm widget
---@field super widget
---@field database types.Database
---@field notebook widget.notebook
---@field plugins widget
---@field themes widget
---@field fonts widget
---@field plugin_sections widget.foldingbook
---@field theme_sections widget.foldingbook
---@field font_sections widget.foldingbook
local Lxpm = Widget:extend()

function Lxpm:new()
  self.super.new(self, false)

  self.name = "LXPM"
  self.defer_draw = false
  self.draggable = false
  self.scrollable = false

  self.notebook = NoteBook(self)
  self.notebook:set_size(300, 300)
  self.notebook.border.width = 0
  do -- Configure panels
    self.plugins = self.notebook:add_pane("plugins", "Plugins")
    self.themes = self.notebook:add_pane("themes", "Themes")
    self.fonts = self.notebook:add_pane("fonts", "Fonts")

    self.plugins.scrollable = false
    self.themes.scrollable = false
    self.fonts.scrollable = false
  end

  do -- Configure sections
    self.plugin_sections = FoldingBook(self.plugins)
    self.plugin_sections.scrollable = false

    self.theme_sections = FoldingBook(self.themes)
    self.theme_sections.scrollable = false

    self.font_sections = FoldingBook(self.fonts)
    self.font_sections.scrollable = false
  end

  self:draw_plugin_list()
end

function Lxpm:draw_plugin_list()
  for id, plugin in ipairs(self.database.plugins) do
    self.plugin_sections:add_pane(id, plugin.name)
  end
end

function Lxpm:get_plugins_list_and_status()
  local result = {}
  for n, package in pairs(self.database.plugins) do
    local plugin = {}
    local files = system.list_dir(USERDIR.."/plugins")
    local dest
    if package.get_type == "directly" then
      dest = common.basename(package.url)
    end
    if common.match_pattern(dest, table.unpack(files)) then
      plugin.status = "Installed"
    end
    table.insert(result, plugin)
  end
  return result
end

function Lxpm:update()
  if not self.super.update(self) then return end
  self.notebook:set_size(self.size.x, self.size.y)
end

return Lxpm
