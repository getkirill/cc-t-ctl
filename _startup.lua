-- DO NOT MODIFY
-- Part of cc-t-ctl
-- This script pools together multiple startup scripts from multiple packages, plus from /autorun.txt
local lib = require("lib")
print("Press F1 for safe mode...")
safe = false
parallel.waitForAny(
  function()
    while true do
      local event, key, is_held = os.pullEvent()
      if key == keys["f1"] and is_held then
        safe = true
        break
      end
    end
  end,
  function()
    os.sleep(3)
  end
)
if safe then
  print("Startup scripts aborted.")
  return
end
for _, package in pairs(lib.installedPackages()) do
  local manifest = lib.packageManifest(package)
  local startupScripts = {"startup.lua"}
  table.insert(startupScripts, manifest.startup or {})
  for _, script in pairs(startupScripts) do
    dofile("/package/"..package.."/"..script)
  end
end
local autorunTxt = fs.open("autorunTxt", "r")
local autorunEntry = autorunTxt.readLine()
while autorunEntry ~= nil do
  dofile(autorunEntry)
  autorunEntry = autorunTxt.readLine()
end