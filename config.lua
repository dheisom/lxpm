return {
  base_url = {
    plugins = "https://github.com/lite-xl/lite-xl-plugins/blob/master/",
    themes = "https://github.com/lite-xl/lite-xl-colors/blob/master/",
    packages = "https://github.com/dheisom/lite-xl-packages/blob/main/",
  },
  db = {
    plugins = "https://raw.githubusercontent.com/lite-xl/lite-xl-plugins/master/README.md",
    themes = "https://raw.githubusercontent.com/lite-xl/lite-xl-colors/master/README.md",
    packages = "https://raw.githubusercontent.com/dheisom/lite-xl-packages/main/README.md",
  },
  patterns = {
    plugins = "%[`([%w|%S]+)%`]%((%S+)%)[ ]+|[ ]+([%w|%S| ]*)|",
    themes = "%[`([%w|%S]+)%`]%((%S+)%)[ ]+|",
    packages = "%[`([%w|%S]+)%`]%((%S+)%)[ ]+|[ ]+([%w|%S| ]*)| "
  },
  ignore_plugins = {
    ["nonicons"] = true -- This is a package due to have to install a specific font
  }
}
