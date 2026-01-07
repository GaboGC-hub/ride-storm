-- core/init.lua
getgenv().RideStorm = getgenv().RideStorm or {}
local RS = getgenv().RideStorm

-- Load core
loadstring(game:HttpGet("https://raw.githubusercontent.com/GaboGC-hub/ride-storm/main/core/state.lua"))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/GaboGC-hub/ride-storm/main/core/window.lua"))()

-- Load features
loadstring(game:HttpGet("https://raw.githubusercontent.com/GaboGC-hub/ride-storm/main/features/delivery.lua"))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/GaboGC-hub/ride-storm/main/features/teleports.lua"))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/GaboGC-hub/ride-storm/main/features/misc.lua"))()
