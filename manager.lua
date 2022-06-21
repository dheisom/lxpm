local common = require('core.common')
local json   = require('plugins.lxpm.json')
local types  = require('plugins.lxpm.types')
local net    = require('plugins.lxpm.net')
local util   = require('plugins.lxpm.util')
local logger = require('plugins.lxpm.logger')

---@class Manager
---@field local_database string
---@field database types.Database
---@field info logger.Logger
local Manager = {}

---Create a new package manager object
---@param local_database string
---@return Manager|nil, string?
function Manager.new(local_database)
  local obj = setmetatable(
    {
      local_database = local_database,
      info = logger:new('[LXPM:Install]')
    },
    { __index = Manager }
  )
  local err = obj:reload_database()
  if err then
    return nil, err
  end
  return obj
end

---@return string? Error message
function Manager:reload_database()
  local ok, err = pcall(function()
    local data = io.open(self.local_database, "r"):read("*a")
    coroutine.yield()
    self.database = json.decode(data)
  end)
  if not ok then
    return "Failed to load database: "..err
  end
end

---Get the list of missing dependencies and returns the arraay containing
---it followed by a list of dependencies not found on the actual database.
---@param plugin types.Plugin
---@return table<integer, types.Plugin|types.Font>, types.Dependence[]
function Manager:get_missing_dependecies(plugin)
  local missing, not_found = {}, {}
  for _, d in ipairs(plugin.depends) do
    local collection = d.type.."s"
    local dependencie = util.find_table_on_array(
      d.name,
      "name",
      self.database[collection]
    )
    local is_installed
    if not dependencie then
      table.insert(not_found, d)
      goto skip
    end
    is_installed = util.is_installed(
      dependencie.name,
      dependencie.type,
      dependencie.folder
    )
    if not is_installed then
      table.insert(missing, dependencie)
    end
    ::skip::
    coroutine.yield()
  end
  return missing, not_found
end

---Install a plugin and your dependencies
---@param package types.Plugin|types.Theme|types.Font
---@param type_ "plugin"|"theme"|"font"
---@return boolean
function Manager:install(package, type_)
  if package.depends then
    -- Install all dependencies
    local missing, not_found = self:get_missing_dependecies(package)
    if #not_found > 0 then
      local message = "The following dependencies has not found:"
      for i, d in ipairs(not_found) do
        message = message..(i == 1 and " " or ", ")..d.name.."("..d.type..")"
      end
      self.info:log(message)
      return false
    end
    for _, dependencie in ipairs(missing) do
      local installed = self:install(dependencie)
      if not installed then
        -- It will return 'false' if one dependencie has not installed in a
        -- recursive mode till the end
        return false
      end
    end
  end
  local default_folder = USERDIR.."/plugins/"..common.basename(plugin.url)
  local ok, err
  if plugin.get_type == types.GetType.CLONE then
    ok, err = net.clone(
      plugin.url,
      plugin.folder or default_folder,
      plugin.branch
    )
  elseif plugin.get_type == types.GetType.DIRECTLY then
    ok, err = net.download(plugin.url, plugin.folder or default_folder)
  end
  if not ok then
    self.info:log("Failed to install '"..plugin.name.."' plugin, error: "..err)
    return false
  end
  return true
end

return Manager
