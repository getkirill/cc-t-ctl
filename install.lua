local function githubRepo(path)
  return function(file)
    return "https://raw.githubusercontent.com/"..path.."/"..file.."?random="..tostring(math.random(10000000))
  end
end
print("Welcome to cc-t-ctl setup!")
local repo = githubRepo("getkirill/cc-t-ctl/main")
local files = {
  "main.lua",
  "install.lua",
  "manifest.lua",
  "pseudocode.txt",
  "README.md"
}
local basePath = "/programs/cc-t-ctl"
for file in files do
  local url = repo(file)
  shell.run("wget", url, basePath..file)
end