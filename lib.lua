local args = {
	...
};
local packagesPath = "/packages";
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
			return true;
		end;
	end;
	return false;
end;
local function readManifest(path)
	local text = (fs.open(path, "r")).readAll();
	return (load(text))();
end;
local function downloadFile(url, location, binary)
	if binary then
	else
		local res = http.get(url, {
			["Cache-Control"] = "Cache-Control: max-age=0, no-cache, must-revalidate, proxy-revalidate"
		});
		local handle = fs.open(location, "w");
		handle.write(res.readAll());
		handle.close();
		res.close();
	end;
end;
local function githubRepo(path)
	return function(file)
		return "https://raw.githubusercontent.com/" .. path .. "/" .. file .. "?random=" .. tostring(math.random(10000000));
	end;
end;
local function gistRepo(path)
	return function(file)
		return "https://gist.githubusercontent.com/" .. path .. "/raw/" .. file .. "?random=" .. tostring(math.random(10000000));
	end;
end;
local function httpRepo(path)
	return function(file)
		return path .. file;
	end;
end;
local function packageFs(location)
	if string.starts(location, "gh:") then
		return githubRepo(string.sub(location, 4));
	elseif string.starts(location, "http:") then
		return httpRepo(string.sub(location, 6));
	elseif string.starts(location, "gist:") then
		return gistRepo(string.sub(location, 6));
	end;
	return function(location)
		return nil;
	end;
end;
local function installedPackages()
	local packages = {};
	for _, file in pairs(fs.list(packagesPath)) do
		table.insert(packages, fs.getName(file));
	end;
	return packages;
end;
local function packageManifest(name)
	return readManifest(packagesPath .. "/" .. name .. "/manifest.lua");
end;
local function scaffoldPackage(manifestUrl)
	fs.makeDir("/tmp");
	downloadFile(manifestUrl, "/tmp/manifest.lua");
	local manifest = readManifest("/tmp/manifest.lua");
	fs.makeDir(packagesPath .. "/" .. manifest.name);
	return manifest;
end;
local function getMetaLocation(packageName)
	local metaLocation = fs.open(packagesPath .. "/" .. packageName .. "/" .. "__meta_location", "r");
	return metaLocation.readAll();
end;
local function setMetaLocation(packageName, packageLocation)
	local metaLocation = fs.open(packagesPath .. "/" .. packageName .. "/" .. "__meta_location", "w");
	metaLocation.write(packageLocation);
	metaLocation.close();
end;
local function installPackage(manifest)
	local packageFs = packageFs(getMetaLocation(manifest.name));
	for _, file in pairs(manifest.files) do
		print("Downloading " .. file .. "...");
		downloadFile(packageFs(file), packagesPath .. "/" .. manifest.name .. "/" .. file);
	end;
	if fs.exists(packagesPath .. "/" .. manifest.name .. "/install.lua") then
		dofile(packagesPath .. "/" .. manifest.name .. "/install.lua");
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
	print("Resolving package " .. packageLocation .. "...");
	local manifest = scaffoldPackage((packageFs(packageLocation))("manifest.lua"));
	if manifest == nil or manifest.name == nil then
		error("Something went wrong resolving manifest.");
	end;
	print("Package: " .. manifest.name .. ", version " .. manifest.version);
	setMetaLocation(manifest.name, packageLocation);
	installPackage(manifest);
	setPackageAliases(manifest);
end;
local function cleanInstall(package)
	print("Clean-installing " .. package .. "...");
	local manifest = packageManifest(package);
	fs.delete(packagesPath .. "/" .. package);
	installPackageCommand(getMetaLocation(package));
end;
local function deletePackage(package)
	print("Deleting " .. package .. "...");
	local manifest = packageManifest(package);
	fs.delete(packagesPath .. "/" .. package);
end;
return {
	packagesPath = packagesPath,
	readManifest = readManifest,
	downloadFile = downloadFile,
	githubRepo = githubRepo,
	httpRepo = httpRepo,
	packageFs = packageFs,
	installedPackages = installedPackages,
	packageManifest = packageManifest,
	scaffoldPackage = scaffoldPackage,
	installPackage = installPackage,
	setPackageAliases = setPackageAliases,
	installPackageCommand = installPackageCommand,
	cleanInstall = cleanInstall,
	getMetaLocation = getMetaLocation,
	deletePackage = deletePackage
};
