local net = {}

local default_options = { stderr = process.REDIRECT_STDOUT }

---Download a file and return if it was executed with success and if not,
---return the error message too
---@param url string
---@param filename string
---@return boolean, string
function net.download(url, filename)
  local proc = process.start({ "curl", "-SLsfk", url, "-o", filename }, default_options)
  while proc:running() do
    coroutine.yield(0.01)
  end
  return proc:returncode() == 0, proc:read_stdout(10e3)
end


---Get data from the URL and return if the operation was executed with success
---and the data received or the error message if it's failed
---@param url string
---@return boolean, string
function net.get(url)
  local proc = process.start({ "curl", "-SLsfk", url }, default_options)
  while proc:running() do
    coroutine.yield(0.01)
  end
  return proc:returncode() == 0, proc:read_stdout(10e6)
end

---Clone a git repository and return the exit code and the stderr output
---@param url string
---@param branch string
---@param folder string
---@return integer, string
function net.clone(url, branch, folder)
  local proc = process.start(
    {
      "git", "clone", "--depth=1", "--recursive", "-q", "--shallow-submodules",
      "--single-branch",
      "-b", branch,
      url, folder
    },
    default_options
  )
  local stderr = ""
  while proc:running() do
    local e = proc:read_stdout(10e3)
    if e ~= nil then
      stderr = stderr .. e
    end
    coroutine.yield(0)
  end
  return proc:returncode(), stderr
end

return net
