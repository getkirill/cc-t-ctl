local lib = require("lib");
print("Press F1 for safe mode...");
safe = false;
parallel.waitForAny(function()
	while true do
		local event, key, is_held = os.pullEvent("key");
		if key == keys.f1 then
			safe = true;
			return;
		end;
	end;
end, function()
	os.sleep(3);
end);
if safe then
	print("Startup scripts aborted.");
	return;
end;
local noRun = {};
if fs.exists("/norun.txt") then
	local norunTxt = fs.open("/norun.txt", "r");
	local norunEntry = norunTxt.readLine();
	while norunEntry ~= nil do
		table.insert(noRun, norunEntry);
		norunEntry = norunTxt.readLine();
	end;
end;
for _, package in pairs(lib.installedPackages()) do
	local manifest = lib.packageManifest(package);
	local startupScripts = {
		"startup.lua"
	};
	if manifest.startup ~= nil then
		for _, script in pairs(manifest.startup) do
			table.insert(startupScripts, script);
		end;
	end;
	for _, script in pairs(startupScripts) do
		if table.contains(noRun, lib.packagesPath .. "/" .. package .. "/" .. script) then
			print("Script " .. script .. " of " .. manifest.name .. " located at '" .. (lib.packagesPath .. "/" .. package .. "/" .. script) .. "' will not run, was defined in '/norun.txt'");
		elseif fs.exists(lib.packagesPath .. "/" .. package .. "/" .. script) then
			print("Running " .. script .. " of " .. manifest.name .. " located at '" .. (lib.packagesPath .. "/" .. package .. "/" .. script) .. "'");
			(loadfile(lib.packagesPath .. "/" .. package .. "/" .. script, _ENV))();
		end;
	end;
end;
if fs.exists("/autorun.txt") then
	local autorunTxt = fs.open("/autorun.txt", "r");
	local autorunEntry = autorunTxt.readLine();
	while autorunEntry ~= nil do
		dofile(autorunEntry);
		autorunEntry = autorunTxt.readLine();
	end;
end;
