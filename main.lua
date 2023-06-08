args = {...}
fs.makeDir("/packages/")
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

local function installedPackages()
  return string.split(fs.open("/packages/index.txt", "r").readAll(), "\n") or {}
end
local function installPackage(manifest)
  fs.makeDir("/packages/"..manifest.name)
  local repo = packageFs(manifest.location)
  for file in manifest.files do
    shell.run("wget", repo(file), "/packages/"..manifest.name.."/"..file)
  end
end