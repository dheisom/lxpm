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


function reload_module()
    core.command_view:enter(
      "Reload Module",
      function(text, item)
        local text = item and item.text or text
        core.reload_module(text)
        core.log("Reloaded module %q", text)
      end,
      function(text)
        local items = {}
        for name in pairs(package.loaded) do
          table.insert(items, name)
        end
        return common.fuzzy_match(items, text)
      end
    )
end
