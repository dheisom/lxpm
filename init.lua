local net = require 'net'
local util = require 'util'

local db_url = "https://raw.githubusercontent.com/lite-xl/lite-xl-plugins/master/README.md"
local data = net.get(db_url)

for _, p in ipairs(util.get_plugins(data)) do
  print(p.name, p.path, p.description)
end
