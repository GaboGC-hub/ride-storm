-- core/window.lua
getgenv().RideStorm = getgenv().RideStorm or {}
local RS = getgenv().RideStorm

-- Load Rayfield
local Rayfield = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/8875383/Rayfield/main/source"
))()

RS.Rayfield = Rayfield

-- Create window
RS.Window = Rayfield:CreateWindow({
    Name = "RideStorm 🏍️",
    LoadingTitle = "RideStorm",
    LoadingSubtitle = "Delivery Hub",
    ConfigurationSaving = { Enabled = false }
})

-- Tabs
RS.Tabs = {
    Delivery = RS.Window:CreateTab("Delivery"),
    Teleports = RS.Window:CreateTab("Teleports"),
    Misc = RS.Window:CreateTab("Misc")
}

-- Sections (IMPORTANT: nunca dejar tabs vacíos)
RS.Sections = {
    Delivery = RS.Tabs.Delivery:CreateSection("Auto Farm"),
    Teleports = RS.Tabs.Teleports:CreateSection("Locations"),
    Misc = RS.Tabs.Misc:CreateSection("Utilities")
}
