-- RideStorm BASE LIMPIA

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Rayfield
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "RideStorm 🏍️",
    LoadingTitle = "RideStorm",
    LoadingSubtitle = "By GaboGC",
    ConfigurationSaving = { Enabled = false }
})

local DeliveryTab = Window:CreateTab("🚚 Delivery")

-- =============================
-- GLOBAL STATE (NO TOCAR MÁS)
-- =============================
getgenv().RideStorm = getgenv().RideStorm or {}
getgenv().RideStorm.BoxFarm = false
getgenv().RideStorm.SpeedFarm = false
getgenv().RideStorm.SpeedStuds = 200

-- =============================
-- 💰 MONEY TRACKER (REAL)
-- =============================
local moneyLabel = DeliveryTab:CreateLabel("💰 Dinero ganado: $0")
local baseMoney

task.spawn(function()
    local stats = player:WaitForChild("leaderstats")
    local cash = stats:WaitForChild("cash")

    baseMoney = cash.Value
    while task.wait(0.5) do
        moneyLabel:Set("💰 Dinero ganado: $" .. (cash.Value - baseMoney))
    end
end)

-- =============================
-- 📦 AUTO DELIVERY
-- =============================
DeliveryTab:CreateToggle({
    Name = "📦 Auto Delivery (Cajas)",
    CurrentValue = false,
    Callback = function(v)
        getgenv().RideStorm.BoxFarm = v
        if v then
            loadstring(game:HttpGet(
                "https://raw.githubusercontent.com/GaboGC-hub/ride-storm/main/autofarm.lua"
            ))()
        end
    end
})

-- =============================
-- 🏍️ SPEED FARM
-- =============================
DeliveryTab:CreateSlider({
    Name = "Velocidad (km/h)",
    Range = {70, 350},
    Increment = 5,
    CurrentValue = 120,
    Callback = function(kmh)
        getgenv().RideStorm.SpeedStuds = kmh / 0.9
    end
})

DeliveryTab:CreateToggle({
    Name = "🏍️ Speed Farm",
    CurrentValue = false,
    Callback = function(v)
        getgenv().RideStorm.SpeedFarm = v
        if v then
            loadstring(game:HttpGet(
                "https://raw.githubusercontent.com/GaboGC-hub/ride-storm/main/speedfarm.lua"
            ))()
        end
    end
})
