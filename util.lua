local core = require 'core'
local process = require 'process'

local util = {}

---@param data string
---@param pattern string
---@return table
function util.parse_data(data, pattern)
  local result = {}
  local match = data:gmatch(pattern)
  while true do
    local matched = { match() }
    if #matched == 0 then break end
    table.insert(result, matched)
  end
  return result
end

---@param str string
---@return string|nil
function util.trim(str)
  if str == nil or str == "" then
    return nil
  end
  str = str:sub(str:find("[%w|%S]")-0):reverse()
  str = str:sub(str:find("[%w|%S]")-0):reverse()
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

---Reads from stream.
---@param proc process
---@param stream process.STREAM_STDERR | process.STREAM_STDOUT
---@param size? integer
---@return string
function util.read(proc, stream, size)
  size = size or 2048
  local readed = 0
  local data = {}
  while readed < size do
    local d = proc:read(stream, size - readed)
    if d == nil or #d == 0 then break end
    table.insert(data, d)
    readed = readed + #d
  end
  return table.concat(data, "")
end


---A non-blocking function to run commands on the system
---@param command table
---@param callback fun(integer, string, string)
function util.run(command, callback)
  local proc = process.start(command)
  while proc:running() do
    coroutine.yield(0.1)
  end
  local read_size = 10485760 -- 10MiB
  local code = proc:returncode()
  local out = util.read(proc, process.STREAM_STDOUT, read_size)
  local err = util.read(proc, process.STREAM_STDERR, read_size)
  core.add_thread(callback, nil, code, out, err)
end

---@param arr table
---@param value any
---@return boolean, table?
function util.contain(arr, value)
  for _, v in ipairs(arr) do
    if v == value then
      return true
    elseif type(v) == "table" and v[1] == value then
      return true, v
    end
  end
  return false
end

return util
