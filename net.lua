local core = require 'core'
local util = require 'plugins.lite-xl-pm.util'

local net = {
  git_status = {
    ok = "cloned",
    exists_or_not_found = "exists or not found",
  }
}

---@param filename string
---@param url string
---@param callback fun(boolean, string)
function net.download(filename, url, callback)
  core.add_thread(
    util.run, nil,
    { "curl", "--stderr", "-", "-SLsfk", url, "-o", filename },
    function(code, _, err) callback(code==0, err) end
  )
end

---@param url string
---@param callback fun(boolean, string)
function net.load(url, callback)
  core.add_thread(
    util.run, nil,
    { "curl", "--stderr", "-", "-SLsfko-", url },
    function(code, result) callback(code==0, result) end
  )
end

---@param url string
---@param path string
---@param callback fun(boolean, string)
function net.clone(url, path, callback)
  core.add_thread(
    util.run, nil,
    { "git", "clone", "--depth=1", url, path },
    function(code)
      local ok, message
      if code == 128 then
        ok, message = false, net.git_status.exists_or_not_found
      elseif code == 0 then
        ok, message = true, net.git_status.ok
      else
        ok, message = false, "unknown error(" .. code .. ")"
      end
      callback(ok, message)
    end
  )
end

return net
