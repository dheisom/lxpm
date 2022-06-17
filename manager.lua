local json   = require('plugins.lxpm.json')
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
    self.database = json.decode(data)
  end)
  if not ok then
    return "Failed to load database: "..err
  end
end

---@param plugin types.Plugin
---@return types.Plugin[]|types.Font[], types.Dependence[]
function Manager:get_missing_dependecies(plugin)
  local missing, not_found, dependencie, is_installed
  missing, not_found = {}, {}
  for _, d in ipairs(plugin.depends) do
    dependencie = util.find_table_on_array(d.name, "name", self.database[d.type.."s"])
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
  end
  return missing, not_found
end

---Install a plugin and your dependencies
---@param plugin types.Plugin
---@return boolean
function Manager:install(plugin)
  local missing_dependencies, not_found_dependencies = self:get_missing_dependecies(plugin)
  if #not_found_dependencies > 0 then
    local message = "The following dependencies has not found:"
    for i, d in ipairs(not_found_dependencies) do
      message = message..(i == 1 and " " or ", ")..d.name.."("..d.type..")"
    end
    self.info:log(message)
    return false
  end
  for _, dependencie in ipairs(missing_dependencies) do
    local installed = self:install(dependencie)
    if not installed then
      return false
    end
  end
  return true
end

return Manager
