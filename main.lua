-- RideStorm Hub (FINAL ESTABLE)

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Rayfield oficial
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "RideStorm 🏍️",
    LoadingTitle = "RideStorm",
    LoadingSubtitle = "By GaboGC",
    ConfigurationSaving = { Enabled = false }
})

-- Tabs
local DeliveryTab = Window:CreateTab("🚚 Delivery")
local MiscTab = Window:CreateTab("⚙️ Misc")

-- =============================
-- GLOBAL STATE
-- =============================
getgenv().RideStorm = getgenv().RideStorm or {}
local RS = getgenv().RideStorm

RS.BoxFarm = false
RS.SpeedFarm = false
RS.MoneyStart = nil

-- =============================
-- MONEY REAL
-- =============================
local function getMoney()
    local stats = player:FindFirstChild("leaderstats")
    if stats and stats:FindFirstChild("Money") then
        return stats.Money.Value
    end
    return 0
end

-- =============================
-- 🚚 DELIVERY UI
-- =============================
DeliveryTab:CreateSection({
    Name = "🚚 Delivery Farm"
})

-- Toggle PRINCIPAL (arriba)
DeliveryTab:CreateToggle({
    Name = "📦 Auto Delivery (Cajas)",
    CurrentValue = false,
    Callback = function(v)
        RS.BoxFarm = v
        if v and not RS.MoneyStart then
            RS.MoneyStart = getMoney()
        end
    end
})

DeliveryTab:CreateToggle({
    Name = "🏍️ Speed Farm (Moto)",
    CurrentValue = false,
    Callback = function(v)
        RS.SpeedFarm = v
        if v and not RS.MoneyStart then
            RS.MoneyStart = getMoney()
        end
    end
})

DeliveryTab:CreateSection({
    Name = "💰 Ganancias"
})

local moneyLabel = DeliveryTab:CreateLabel("💰 Dinero ganado: $0")

task.spawn(function()
    while task.wait(0.5) do
        if RS.
