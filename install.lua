println("Installing startup script...")
local startup = fs.open("/startup.lua", "w")
startup.write('dofile("/packages/cc-t-ctl/_startup.lua")')
startup.close()