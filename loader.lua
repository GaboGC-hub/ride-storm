-- RideStorm Loader
if getgenv().RideStormLoaded then return end
getgenv().RideStormLoaded = true

local base = "https://raw.githubusercontent.com/GaboGC-hub/ride-storm/main/"

local function load(path)
    local src = game:HttpGet(base .. path)
    return loadstring(src)()
end

load("core/init.lua")
