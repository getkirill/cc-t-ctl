print("Installing startup script...")
local startup = fs.open("/startup.lua", "w")
startup.write('package.path = package.path .. ";/packages/cc-t-ctl/lib.lua";loadfile("/packages/cc-t-ctl/_startup.lua", _ENV)()')
startup.close()