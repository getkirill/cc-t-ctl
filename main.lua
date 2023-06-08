local args = {...}
local lib = require("lib")
if args[1] == "install" then
	lib.installPackageCommand(args[2]);
end;
if args[1] == "clean-install" then
	lib.cleanInstall(args[2]);
end;
if args[1] == "list" then
	for _, package in pairs(lib.installedPackages()) do
		print(package);
	end;
end;
if args[1] == "update" then
	for _, package in pairs(lib.installedPackages()) do
		lib.installPackageCommand(lib.getMetaLocation(package));
	end;
end;
