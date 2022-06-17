local util = {}

---@param folder string
---@return string
local function format_folder(folder)
  folder = folder:gsub("{USERDIR}", USERDIR)
  folder = folder:gsub("{DATADIR}", DATADIR)
  return folder
end

---@param basename string
---@param type_ "plugin"|"theme"|"font"
---@param folder? string
---@return boolean
function util.is_installed(basename, type_, folder)
  if folder then
    local i = system.get_file_info(format_folder(folder))
    return i ~= nil
  end
  local path
  if type_ == "plugin" then
    path = "/plugins/"
  elseif type_ == "theme" then
    path = "/colors/"
  elseif type_ == "font" then
    path = "/fonts/"
  end
  local asroot = DATADIR..path..basename
  local asuser = USERDIR..path..basename
  if type_ == "font" then
    asroot = asroot..".ttf"
    asuser = asuser..".ttf"
  end
  if system.get_file_info(asroot) or system.get_file_info(asuser) then
    return true
  end
  return false
end

---@param value any
---@param key string|integer
---@param array table[]
function util.find_table_on_array(value, key, array)
  for _, tb in pairs(array) do
    if tb[key] == value then
      return tb
    end
  end
  return nil
end

return util
