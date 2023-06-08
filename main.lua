args = {
	...
};
packagesPath = "/packages";
fs.makeDir(packagesPath);
function string.split(inputstr, sep)
	if sep == nil then
		sep = "%s";
	end;
	local t = {};
	for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
		table.insert(t, str);
	end;
	return t;
end;
function string.starts(String, Start)
	return string.sub(String, 1, string.len(Start)) == Start;
end;
function table.contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

function readManifest(path)
	local text = (fs.open(path, "r")).readAll();
	return (load(text))();
end;
function downloadFile(url, location, binary)
	if binary then
	else
    local res = http.get(url, {["Cache-Control"] = "Cache-Control: max-age=0, no-cache, must-revalidate, proxy-revalidate"})
		local handle = fs.open(location, "w")
    handle.write(res.readAll())
    handle.close()
    res.close()
	end;
end;
local function githubRepo(path)
	return function(file)
		return "https://raw.githubusercontent.com/" .. path .. "/" .. file .. "?random=" .. tostring(math.random(10000000));
	end;
end;
local function httpRepo(path)
  return function(file)
		return path..file
	end;
end
local function packageFs(location)
	if string.starts(location, "gh:") then
		return githubRepo(string.sub(location, 4));
  elseif string.starts(location, "http:") then
		return httpRepo(string.sub(location, 6));
  end;
	return function(location)
		return nil;
	end;
end;

local function installedPackages()
  local packages = {}
  for _, file in pairs(fs.list(packagesPath)) do
    table.insert(packages, fs.getName(file))
  end
  return packages
end
local function packageManifest(name)
  return readManifest(packagesPath.."/"..name.."/manifest.lua")
end
local function scaffoldPackage(manifestUrl)
	fs.makeDir("/tmp");
	downloadFile(manifestUrl, "/tmp/manifest.lua");
	local manifest = readManifest("/tmp/manifest.lua");
	fs.makeDir(packagesPath .. "/" .. manifest.name);
	return manifest;
end;
local function installPackage(manifest)
	local packageFs = packageFs(manifest.location);
	for _, file in pairs(manifest.files) do
    print("Downloading "..file.."...")
		downloadFile(packageFs(file), packagesPath .. "/" .. manifest.name .. "/" .. file);
	end;
end;
local function setPackageAliases(manifest)
	local aliases = manifest.aliases or {};
	if fs.exists(packagesPath .. "/" .. manifest.name .. "/main.lua") then
		aliases[manifest.name] = aliases[manifest.name] or "main.lua";
	end;
	for alias, value in pairs(aliases) do
		print("Setting alias " .. alias .. " to " .. packagesPath .. "/" .. manifest.name .. "/" .. value);
		shell.setAlias(alias, packagesPath .. "/" .. manifest.name .. "/" .. value);
	end;
end;
local function installPackageCommand(packageLocation)
  print("Resolving package "..packageLocation.."...")
	local manifest = scaffoldPackage((packageFs(packageLocation))("manifest.lua"));
	installPackage(manifest);
	setPackageAliases(manifest);
end;
local function cleanInstall(package)
  local manifest = readManifest(package)
  fs.delete(packagesPath .. "/" .. package)
  installPackageCommand(manifest.location)
end

if args[1] == "install" then
	installPackageCommand(args[2]);
end;
if args[1] == "clean-install" then
  if args[2] ~= nil then
    cleanInstall(args[2])
  end
	--todo add cleaning
end;
if args[1] == "list" then
	for _, package in pairs(installedPackages()) do
    print(package)
  end
end;
if args[1] == "update" then
  for _, package in pairs(installedPackages()) do
    installPackageCommand(packageManifest(package).location)
  end
end