local util = require 'plugins.lite-xl-pm.util'

local net = {
  git_status = {
    ok = "cloned",
    exists_or_not_found = "exists or not found",
  }
}

---@param filename string
---@param url string
---@return boolean ok, string error
function net.download(filename, url)
  local code, _, err = util.run(
    { "curl", "--stderr", "-", "-SLsfk", url, "-o", filename }
  )
  return (code == 0), err
end

---@param url string
---@return boolean ok, string result, string error
function net.load(url)
  local code, result, err = util.run(
    { "curl", "--stderr", "-", "-SLsfko-", url }
  )
  return (code == 0), result, err
end

---@param url string
---@param path string
---@return boolean ok, string message
function net.clone(url, path)
  local code = util.run({ "git", "clone", "--depth=1", url, path })
  if code == 128 then
    return false, net.git_status.exists_or_not_found
  elseif code == 0 then
    return true, net.git_status.ok
  else
    return false, "unknown error(" .. code .. ")"
  end
end

return net
