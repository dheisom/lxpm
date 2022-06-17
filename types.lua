local types = {}

---Types of download compatibles
---@type table<string, string>
types.GetType = {
  DIRECTLY = "directly",
  CLONE    = "clone"
}

---@alias types.GetType
---|>'types.GetType.DIRECTLY'
---| 'types.GetType.CLONE'

---@type table<string, string>
types.DependenceType = {
  PLUGIN = "plugin",
  FONT   = "font"
}

---@alias types.DependenceType
---|> 'types.DependenceType.PLUGIN'
---|  'types.DependenceType.FONT'

---@class types.Dependence
---@field type types.DependenceType
---@field name string
types.Dependence = {}

---@class types.Plugin
---@field name string
---@field description string
---@field get_type types.GetType
---@field url string
---@field depends? types.Dependence[]
---@field folder? string
---@field branch? string
types.Plugin = {}

---@class types.Theme
---@field name string
---@field description string
---@field url string
types.Theme = {}

---@class types.Font types.Theme
types.Font = {}

---@class types.Database
---@field plugins types.Plugin[]
---@field themes types.Theme[]
---@field fonts types.Font[]
types.Database = {}

return types
