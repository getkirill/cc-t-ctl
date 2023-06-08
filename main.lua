args = {...}
packagesPath = "/packages"
fs.makeDir(packagesPath)
function string.split (inputstr, sep)
  if sep == nil then
          sep = "%s"
  end
  local t={}
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
          table.insert(t, str)
  end
  return t
end
function string.starts(String,Start)
  return string.sub(String,1,string.len(Start))==Start
end
function readManifest(path)
  local text = fs.open(path, "r").readAll()
  return load(text)()
end

local function githubRepo(path)
  return function(file)
    return "https://raw.githubusercontent.com/"..path.."/"..file.."?random="..tostring(math.random(10000000))
  end
end

local function packageFs(location)
  if string.starts(location, "gh:") then
    return githubRepo(string.sub(location, 4))
  end
  return function (location) return nil end
end

-- local function installedPackages()
--   return string.split(fs.open(packagesPath.."/index.txt", "r").readAll(), "\n") or {}
-- end
local function scaffoldPackage(manifestUrl)
  fs.makeDir("/tmp")
  shell.run("wget", manifestUrl, "/tmp/manifest.lua")
  local manifest = readManifest("/tmp/manifest.lua")
  fs.makeDir(packagesPath.."/"..manifest.name)
  if fs.exists(packagesPath.."/"..manifest.name.."/manifest.lua") then
    fs.delete(packagesPath.."/"..manifest.name.."/manifest.lua")
  end
  fs.move("/tmp/manifest.lua", packagesPath.."/"..manifest.name.."/manifest.lua")
  return manifest
end
local function installPackage(manifest)
  local packageFs = packageFs(manifest.location)
  for _, file in pairs(manifest.files) do
    if fs.exists(packagesPath.."/"..manifest.name.."/"..file) then
      fs.delete(packagesPath.."/"..manifest.name.."/"..file) -- these are hacks, i will make custom wget later
    end
    shell.run("wget", packageFs(file), packagesPath.."/"..manifest.name.."/"..file)
  end
end
local function setPackageAliases(manifest)
  local aliases = manifest.aliases or {}
  if fs.exists(packagesPath.."/"..manifest.name.."/main.lua") then
    aliases[manifest.name] = aliases[manifest.name] or "main.lua"
  end
  for alias, value in pairs(aliases) do
    print("Setting alias "..alias.." to "..packagesPath.."/"..manifest.name.."/"..value)
    shell.setAlias(alias, packagesPath.."/"..manifest.name.."/"..value)
  end
end

local function installPackageCommand(packageLocation)
  local manifest = scaffoldPackage(packageFs(packageLocation)("manifest.lua"))
  installPackage(manifest)
  setPackageAliases(manifest)
end

-- TODO: Use mpeterv/argparse
if args[1] == "install" then
  installPackageCommand(args[2])
end