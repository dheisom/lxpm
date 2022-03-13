local core = require 'core'

---@class Logger
---@field prefix string
local Logger = {}
Logger.__index = Logger

---@param prefix string
---@return Logger
function Logger:new(prefix)
  prefix = prefix or "[%Y/%m/%d %H:%M:%S]"
  return setmetatable({ prefix = prefix }, Logger)
end

---@param msg string
---@param ... any
function Logger:log(msg, ...)
  local text = msg:format(...)
  core.log(os.date(self.prefix) .. " " .. text)
end

---@param msg string
function Logger:error(msg, ...)
  local text = msg:format(...)
  core.error(os.date(self.prefix) .. " " .. text)
end

return setmetatable({}, Logger)
