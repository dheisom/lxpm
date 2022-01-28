local core = require 'core'

-- Replace the core.add_thread to support extra arguments that is passed
-- to the function
function core.add_thread(f, weak_ref, ...)
  local key = weak_ref or #core.threads + 1
  local args = {...}
  local unpack = unpack or table.unpack
  local fn = function() return core.try(f, unpack(args)) end
  core.threads[key] = { cr = coroutine.create(fn), wake = 0 }
  return key
end
