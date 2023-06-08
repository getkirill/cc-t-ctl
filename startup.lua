local lib = require("lib")
-- fix aliases for CraftOS-PC (?)
for _, package in pairs(lib.installedPackages()) do
  lib.setPackageAliases(lib.packageManifest(package))
end
print("No package updates available.") -- heh