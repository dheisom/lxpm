local core = require 'core'
local util = require 'plugins.lxpm.util'

local net = {
  gs = {
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
    { "curl", "-SLsfk", url, "-o", filename },
    function(code, _, err) callback(code==0, err) end
  )
end

---@param url string
---@param callback fun(boolean, string, string)
function net.load(url, callback)
  core.add_thread(
    util.run, nil,
    { "curl", "-SLsfko-", url },
    function(code, ...) callback(code==0, ...) end
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
        ok, message = false, net.gs.exists_or_not_found
      elseif code == 0 then
        ok, message = true, net.gs.ok
      else
        ok, message = false, "unknown error(" .. code .. ")"
      end
      callback(ok, message)
    end
  )
end

return net
