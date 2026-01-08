-- RideStorm Hub (ESTABLE)

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Rayfield (OFICIAL)
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
-- GLOBAL STATE (ÚNICO)
-- =============================
getgenv().RideStorm = getgenv().RideStorm or {}
local RS = getgenv().RideStorm

RS.BoxFarm = false
RS.SpeedFarm = false
RS.MoneyStart = nil

-- =============================
-- MONEY (REAL)
-- =============================
local function getMoney()
    local stats = player:FindFirstChild("leaderstats")
    if stats and stats:FindFirstChild("Money") then
        return stats.Money.Value
    end
    return 0
end

-- =============================
-- 📦 DELIVERY SECTION
-- =============================
DeliveryTab:CreateSection({
    Name = "📦 Delivery Farm"
})

local moneyLabel = DeliveryTab:CreateLabel("💰 Dinero ganado: $0")

-- contador REAL
task.spawn(function()
    while task.wait(0.5) do
        if RS.MoneyStart then
            local gained = getMoney() - RS.MoneyStart
            moneyLabel:Set("💰 Dinero ganado: $" .. math.max(gained, 0))
        end
    end
end)

-- =============================
-- LOAD FARMS ONCE
-- =============================
pcall(function()
    loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/GaboGC-hub/ride-storm/main/autofarm.lua"
    ))()
end)

pcall(function()
    loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/GaboGC-hub/ride-storm/main/speedfarm.lua"
    ))()
end)

-- =============================
-- TOGGLES
-- =============================
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

-- =============================
-- MISC
-- =============================
MiscTab:CreateButton({
    Name = "🔄 Reiniciar contador",
    Callback = function()
        RS.MoneyStart = getMoney()
    end
})

Rayfield:Notify({
    Title = "RideStorm",
    Content = "Hub cargado correctamente",
    Duration = 4
})
