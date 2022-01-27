local util = {}

---@param readme string
---@return table
function util.get_plugins(readme)
  local result = {}
  local pattern = "%[`([%w|_]+)%`]%((%S+)%)[ ]+|[ ]+([%w|%S| ]*)|"
  for name, path, description in readme:gmatch(pattern) do
    table.insert(
      result,
      {
        name=util.trim(name),
        path=util.trim(path),
        description=util.trim(description)
      }
    )
  end
  return result
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

return util
