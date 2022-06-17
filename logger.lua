-- A stupid log lib that supports message prefix

local core = require 'core'

---@class logger.Logger
---@field prefix string
local Logger = {}
Logger.__index = Logger

---@param prefix string
---@return logger.Logger
function Logger:new(prefix)
  prefix = (prefix and prefix .. " ") or ""
  return setmetatable({ prefix = prefix }, Logger)
end

---@param msg string
---@param ... any
function Logger:log(msg, ...)
  local text = msg:format(...)
  core.log(self.prefix .. text)
end

---@param msg string
---@param ... any
function Logger:error(msg, ...)
  local text = msg:format(...)
  core.error(self.prefix .. text)
end

return setmetatable({}, Logger)
