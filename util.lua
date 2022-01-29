local core = require 'core'

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
  str = str:sub(str:find("[%w|%S]")-1):reverse()
  str = str:sub(str:find("[%w|%S]")-1):reverse()
  return (str ~= "" and str or nil)
end

---@param command table
---@param callback fun(ok: boolean, out: string)
function util.run(command, callback)
  local proc = process.start(command)
  while proc:running() do
    coroutine.yield(2)
  end
  local read_size = 5 * 1048576 -- 5MiB
  core.add_thread(
    callback, nil,
    proc:returncode() == 0, -- If true, the command runs with success
    proc:read_stdout(read_size) or proc:read_stderr(read_size) or ""
  )
end

return util
