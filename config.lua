return {
  base_url = {
    plugins = "https://github.com/lite-xl/lite-xl-plugins/blob/master/",
    themes = "https://github.com/lite-xl/lite-xl-colors/blob/master/",
  },
  db = {
    plugins = "https://raw.githubusercontent.com/lite-xl/lite-xl-plugins/master/README.md",
    themes = "https://raw.githubusercontent.com/lite-xl/lite-xl-colors/master/README.md",
  },
  patterns = {
    plugins = "%[`([%w|%S]+)%`]%((%S+)%)[ ]+|[ ]+([%w|%S| ]*)|",
    themes = "%[`([%w|%S]+)%`]%((%S+)%)[ ]+|"
  },
  ignore_plugins = {
    ["nonicons"] = true -- This is a package due to have to install a specific font
  }
}
