local core = require 'core'
local util = require 'plugins.lite-xl-pm.util'

local net = {}

---@param filename string
---@param url string
---@param callback function
function net.download(filename, url, callback)
  core.add_thread(util.run, nil, { "curl", "-sL", url, "-o", filename}, callback)
end

---@param url string
---@param callback function
function net.load(url, callback)
  core.add_thread(util.run, nil, { "curl", "-sLo-", url }, callback)
end

return net
