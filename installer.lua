local args = {...}
local function githubRepo(path)
	return function(file)
		return "https://raw.githubusercontent.com/" .. path .. "/" .. file .. "?random=" .. tostring(math.random(10000000));
	end;
end;
local function httpRepo(path)
	return function(file)
		return path .. file;
	end;
end;
function downloadFile(url, location)
	local res = http.get(url, {["Cache-Control"] = "Cache-Control: max-age=0, no-cache, must-revalidate, proxy-revalidate"});
	local handle = fs.open(location, "w");
	handle.write(res.readAll());
	handle.close();
	res.close();
end;
function readManifest(path)
	local text = (fs.open(path, "r")).readAll();
	return (load(text))();
end;
print("Welcome to cc-t-ctl setup!");
local repo = nil
if args[1] == "local" then
	repo = httpRepo("http://localhost:8080/")
else
	repo = githubRepo("getkirill/cc-t-ctl/main");
end
local basePath = "/packages/cc-t-ctl/";
if fs.exists(basePath) and fs.isDir(basePath) then
	print("Previous installation detected, removing folder...");
	fs.delete(basePath);
end;
fs.makeDir(basePath);
downloadFile(repo("manifest.lua"), basePath .. "manifest.lua");
local manifest = readManifest(basePath .. "manifest.lua");
for _, file in pairs(manifest.files) do
	downloadFile(repo(file), basePath .. file);
end;
print("Downloading finished, transferring control to cc-t-ctl...");
if args[1] == "local" then
	shell.run(basePath .. "main.lua", "install", "http:http://localhost:8080/");
else
	shell.run(basePath .. "main.lua", "install", "gh:getkirill/cc-t-ctl/main");
end

