local core = require 'core'
local process = require 'process'
local pmconfig = require 'plugins.lite-xl-pm.config'

local util = {}

---@param data string
---@param pattern string
---@return table,integer
function util.parse_data(data, pattern)
  local result, size = {}, 0
  for name, path, description in data:gmatch(pattern) do
    if pattern == pmconfig.patterns.plugins then
      if pmconfig.ignore_plugins[util.trim(name)] then
        goto skip
      end
    end
    result[util.trim(name)] = {
      path=util.trim(path),
      description=util.trim(description or "")
    }
    size = size + 1
    ::skip::
  end
  return result, size
end

---@param str string
---@return string|nil
function util.trim(str)
  if str == nil or str == "" then
    return nil
  end
  str = str:sub(str:find("[%w|%S]")-1):reverse()
  str = str:sub(str:find("[%w|%S]")-1):reverse()
  return str
end

---@param str string
---@param sep string
---@return table
function util.split(str, sep)
  if str == nil then return {} end
  sep = sep or "[ |\n]"
  local result = {}
  while true do
    local new = str:find(sep)
    if new == nil then
      if str ~= "" then table.insert(result, str) end
      break
    end
    local text = str:sub(1, new-1)
    if text ~= "" then table.insert(result, text) end
    str = str:sub(new+1)
  end
  return result
end

---A non-blocking function to run commands on the system
---@param command table
---@return integer returncode, string stdout, string stderr
function util.run(command)
  local proc = process.start(command)
  while proc:running() do
    coroutine.yield(0.1)
  end
  local read_size = 5 * 1048576 -- 5MiB
  local code = proc:returncode()
  local out = proc:read_stdout(read_size)
  local err = proc:read_stderr(read_size)
  return code, out, err
end

return util
