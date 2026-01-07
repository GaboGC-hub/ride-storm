-- features/delivery.lua
local RS = getgenv().RideStorm
if not RS or not RS.Sections then return end

local player = game.Players.LocalPlayer

RS.Sections.Delivery:CreateToggle({
    Name = "Auto Delivery",
    CurrentValue = false,
    Callback = function(v)
        RS.State.Autofarm = v
        warn("Auto Delivery:", v)
        -- aquí luego metes el loop real
    end
})
