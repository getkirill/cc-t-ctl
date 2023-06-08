local function githubRepo(path)
	return function(file)
		return "https://raw.githubusercontent.com/" .. path .. "/" .. file .. "?random=" .. tostring(math.random(10000000));
	end;
end;
function downloadFile(url, location)
  local res = http.get(url)
		(fs.open(location, "w")).write((res).readAll());
    res.close()
end;
function readManifest(path)
	local text = (fs.open(path, "r")).readAll();
  print(text)
	return (load(text))();
end;
print("Welcome to cc-t-ctl setup!");
local repo = githubRepo("getkirill/cc-t-ctl/main");
local basePath = "/packages/cc-t-ctl/";
if fs.exists(basePath) and fs.isDir(basePath) then
	print("Previous installation detected, removing folder...");
	fs.delete(basePath);
end;
downloadFile(repo("manifest.lua"), basePath .. "manifest.lua");
os.sleep(0.1)
local manifest = readManifest(basePath .. "manifest.lua");
print(fs.exists(basePath .. "manifest.lua"))
print(textutils.serialise(manifest))
for _, file in pairs(manifest.files) do
	downloadFile(repo(file), basePath .. file);
end;
print("Downloading finished, package installing...")
shell.run(basePath.."main.lua", "install", "gh:getkirill/cc-t-ctl/main")