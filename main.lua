-- =====================================
-- RideStorm Hub (STABLE BOOT)
-- =====================================

-- 🔒 Evitar doble ejecución
if getgenv().RideStormLoaded then return end
getgenv().RideStormLoaded = true

-- =====================================
-- SERVICIOS
-- =====================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- =====================================
-- CARGAR RAYFIELD (FORMA OFICIAL)
-- =====================================
local Rayfield
do
    local ok, lib = pcall(function()
        return loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
    end)
    if not ok or not lib then
        warn("❌ RideStorm: Rayfield no cargó")
        return
    end
    Rayfield = lib
end

-- =====================================
-- WINDOW
-- =====================================
local Window = Rayfield:CreateWindow({
    Name = "RideStorm 🏍️",
    LoadingTitle = "RideStorm",
    LoadingSubtitle = "By GaboGC",
    ConfigurationSaving = { Enabled = false }
})

-- =====================================
-- TABS
-- =====================================
local DeliveryTab = Window:CreateTab("🚚 Delivery")
local MiscTab     = Window:CreateTab("⚙️ Misc")

-- =====================================
-- GLOBAL STATE
-- =====================================
getgenv().RideStorm = {
    BoxFarm = false,
    SpeedFarm = false,
    MoneyStart = 0
}

-- =====================================
-- MONEY (REAL)
-- =====================================
local function getMoney()
    local stats = player:FindFirstChild("leaderstats")
    if stats and stats:FindFirstChild("Money") then
        return stats.Money.Value
    end
    return 0
end

-- =====================================
-- UI: DELIVERY
-- =====================================
DeliveryTab:CreateSection("📦 Delivery Farm")

local moneyLabel = DeliveryTab:CreateLabel("💰 Dinero ganado: $0")

task.spawn(function()
    while task.wait(0.5) do
        if getgenv().RideStorm.MoneyStart > 0 then
            local gained = getMoney() - getgenv().RideStorm.MoneyStart
            moneyLabel:Set("💰 Dinero ganado: $" .. math.max(gained, 0))
        end
    end
end)

-- =====================================
-- AUTOFARM CAJAS
-- =====================================
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

-- =====================================
-- SPEED FARM
-- =====================================
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

-- =====================================
-- MISC
-- =====================================
MiscTab:CreateButton({
    Name = "🔁 Reset contador",
    Callback = function()
        getgenv().RideStorm.MoneyStart = getMoney()
    end
})

Rayfield:Notify({
    Title = "RideStorm",
    Content = "Hub cargado correctamente",
    Duration = 4
})
