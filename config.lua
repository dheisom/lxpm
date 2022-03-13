local config = {}
local github = "https://github.com/%s/blob/%s/"
local github_readme = "https://raw.githubusercontent.com/%s/%s/README.md"

config.base_url = {
  plugins = github:format("lite-xl/lite-xl-plugins", "master"),
  themes = github:format("lite-xl/lite-xl-colors", "master"),
  packages = github:format("dheisom/lite-xl-packages", "main")
}

config.db = {
  plugins = github_readme:format("lite-xl/lite-xl-plugins", "master"),
  themes = github_readme:format("lite-xl/lite-xl-colors", "master"),
  packages = github_readme:format("dheisom/lite-xl-packages", "main"),
}

config.patterns = {
  plugins = "`(%S+)`]%((plugins/%S+)%)[ ]+| ([%w|%S| ]+) |",
  themes = "`(%S+)`]%((colors/%S+)%)",
  packages = "`(%S+)`]%((packages/%S+)%)[ ]+| ([%w|%S| ]+)% | "
}

config.ignore_plugins = {
  "nonicons" -- This is a package due to have to install a specific font
}

return config
