local core = require 'core'

-- Replace the core.add_thread to support extra arguments that is passed
-- to the function
function core.add_thread(f, weak_ref, ...)
  local key = weak_ref or #core.threads + 1
  local args = {...}
  -- To runs on Lua 5.1 and 5.4
  local tunpack = rawget(_G, 'unpack') or rawget(table, 'unpack')
  local fn = function() return core.try(f, tunpack(args)) end
  core.threads[key] = { cr = coroutine.create(fn), wake = 0 }
  return key
end
