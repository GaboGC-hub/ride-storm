local Players = game:GetService("Players")
local player = Players.LocalPlayer

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "RideStorm 🏍️",
    LoadingTitle = "RideStorm",
    LoadingSubtitle = "By GaboGC",
    ConfigurationSaving = { Enabled = false }
})

local DeliveryTab = Window:CreateTab("🚚 Delivery")
local MiscTab = Window:CreateTab("⚙️ Misc")

-- =============================
-- GLOBAL STATE
-- =============================
getgenv().RideStorm = {
    BoxFarm = false,
    SpeedFarm = false,
    MoneyStart = 0
}

-- =============================
-- MONEY PATH (REAL)
-- =============================
local function getMoney()
    local stats = player:FindFirstChild("leaderstats")
    if stats and stats:FindFirstChild("Money") then
        return stats.Money.Value
    end
    return 0
end

-- =============================
-- 🚚 DELIVERY SECTION
-- =============================
local deliverySection = DeliveryTab:CreateSection("📦 Delivery Farm")

local moneyLabel = DeliveryTab:CreateLabel("💰 Dinero ganado: $0")

-- actualizar dinero REAL
task.spawn(function()
    while task.wait(0.5) do
        if getgenv().RideStorm.MoneyStart > 0 then
            local gained = getMoney() - getgenv().RideStorm.MoneyStart
            moneyLabel:Set("💰 Dinero ganado: $" .. math.max(gained, 0))
        end
    end
end)

-- AUTOFARM CAJAS (RESTAURADO)
DeliveryTab:CreateToggle({
    Name = "📦 Auto Delivery (Cajas)",
    CurrentValue = false,
    Callback = function(v)
        getgenv().RideStorm.BoxFarm = v
        if v then
            getgenv().RideStorm.MoneyStart = getMoney()
            loadstring(game:HttpGet(
                "https://raw.githubusercontent.com/GaboGC-hub/ride-storm/main/autofarm.lua"
            ))()
        end
    end
})

-- =============================
-- 🏍️ SPEED FARM
-- =============================
DeliveryTab:CreateToggle({
    Name = "🏍️ Speed Farm (Moto)",
    CurrentValue = false,
    Callback = function(v)
        getgenv().RideStorm.SpeedFarm = v
        if v then
            getgenv().RideStorm.MoneyStart = getMoney()
            loadstring(game:HttpGet(
                "https://raw.githubusercontent.com/GaboGC-hub/ride-storm/main/speedfarm.lua"
            ))()
        end
    end
})
