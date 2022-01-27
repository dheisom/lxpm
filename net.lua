-- A tiny Curl wrapper for lite-xl-pm
local net = {}

---@param url string
---@return string
function net.get(url)
  local command = ("curl -sf '%s'"):format(url)
  local running = io.popen(command, "r")
  local response = running:read("*a")
  running:close()
  return response
end

---@param url string
---@param filename string
---@return boolean
function net.save(url, filename)
  local command = ("curl -sf '%s' -o '%s'"):format(url, filename)
  local exitcode = os.popen(command)
  if exitcode == 0 then
    return true
  end
  return false
end

return net
