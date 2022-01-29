local util = {}

---@param readme string
---@return (table,integer)
function util.get_plugins(readme)
  local result = {}
  local size = 0
  local pattern = "%[`([%w|%S]+)%`]%((%S+)%)[ ]+|[ ]+([%w|%S| ]*)|"
  for name, path, description in readme:gmatch(pattern) do
    result[util.trim(name)] = {
      path=util.trim(path),
      description=util.trim(description)
    }
    size = size + 1
  end
  return result, size
end

---@param readme string
---@return (table,integer)
function util.get_colors(readme)
  local result = {}
  local size = 0
  local pattern = "%[`([%w|%S]+)%`]%((%S+)%)[ ]+|"
  for name, path in readme:gmatch(pattern) do
    result[util.trim(name)] = { path=util.trim(path) }
    size = size + 1
  end
  return result, size
end

---@param str string
---@return string
function util.trim(str)
  local start = 1
  local stop = #str
  for i=1, #str, 1 do
    if str:sub(i, i) ~= " " then
      start = i
      break
    end
  end
  for i=#str, 1, -1 do
    if str:sub(i, i) ~= " " then
      stop = i
      break
    end
  end
  return str:sub(start, stop)
end

---@param command table
---@param callback function(ok: boolean, out: string)
function util.run(command, callback)
  local proc = process.start(command)
  --- Wait until the program close
  while true do
    if not proc:running() then
      break
    end
    coroutine.yield(2)
  end
  local read_size = 5 * 1048576 -- 5MiB
  callback(
    proc:returncode() == 0, -- If true, the command runs with success
    proc:read_stdout(read_size) or proc:read_stderr(read_size) or ""
  )
end

return util

