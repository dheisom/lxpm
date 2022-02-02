local core = require 'core'
local system = require 'system'

local util = {}

---@param data string
---@param pattern string
---@return (table, integer)
function util.parse_data(data, pattern)
  local result, size = {}, 0
  for name, path, description in data:gmatch(pattern) do
    result[util.trim(name)] = {
      path=util.trim(path),
      description=util.trim(description or "")
    }
    size = size + 1
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
---@return table<string>
function util.split(str, sep)
  if str == nil then return {} end
  local sep = sep or "[ |\n]"
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

---@param command table
---@param callback fun(ok: boolean, out: string)
function util.run(command, callback)
  local proc = process.start(command)
  while proc:running() do
    coroutine.yield(1)
  end
  local read_size = 5 * 1048576 -- 5MiB
  local ok, out
  if proc:returncode() ~= 0 then
    ok = false
    out = proc:read_stderr(read_size)
  else
    ok = true
    out = proc:read_stdout(read_size)
  end
  core.add_thread(callback, nil, ok, out)
end

return util
