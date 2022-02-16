local core = require 'core'

local logger = {}

---@param prefix string
---@return table
function logger:new(prefix)
  prefix = prefix or "[%Y/%m/%d %H:%M:%S]"
  return setmetatable({ prefix = prefix }, logger)
end

function logger:__index(key)
  return logger[key]
end

---@param msg string
---@param ... any
function logger:log(msg, ...)
  local text = msg:format(...)
  core.log(os.date(self.prefix) .. " " .. text)
end

---@param msg string
function logger:error(msg, ...)
  local text = msg:format(...)
  core.error(os.date(self.prefix) .. " " .. text)
end

return setmetatable({}, logger)
