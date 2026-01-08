-- RideStorm HUB (ESTABLE)

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- =============================
-- RAYFIELD (OFICIAL)
-- =============================
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "RideStorm 🏍️",
    LoadingTitle = "RideStorm",
    LoadingSubtitle = "By GaboGC",
    ConfigurationSaving = { Enabled = false }
})

-- =============================
-- TABS
-- =============================
local DeliveryTab = Window:CreateTab("🚚 Delivery", 4483362458)
local MiscTab     = Window:CreateTab("⚙️ Misc", 4483362458)

-- =============================
-- GLOBAL STATE
-- =============================
getgenv().RideStorm = {
    BoxFarm = false,
    SpeedFarm = false,
    MoneyStart = nil
}

-- =============================
-- MONEY PATH REAL
-- =============================
local function getMoney()
    local stats = player:FindFirstChild("leaderstats")
    if stats and stats:FindFirstChild("Money") then
        return stats.Money.Value
    end
    return 0
end

-- =============================
-- DELIVERY SECTION
-- =============================
local DeliverySection = DeliveryTab:CreateSection({
    Name = "📦 Delivery Farm"
})

local moneyLabel = DeliveryTab:CreateLabel("💰 Dinero ganado: $0")

task.spawn(function()
    while task.wait(0.5) do
        if getgenv().RideStorm.MoneyStart then
            local gained = getMoney() - getgenv().RideStorm.MoneyStart
            moneyLabel:Set("💰 Dinero ganado: $" .. math.max(gained, 0))
        end
    end
end)

-- =============================
-- AUTO DELIVERY (CAJAS)
-- =============================
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
-- SPEED FARM
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

-- =============================
-- MISC SECTION
-- =============================
local MiscSection = MiscTab:CreateSection({
    Name = "⚙️ Utilities"
})

MiscTab:CreateButton({
    Name = "♻️ Reset Contador",
    Callback = function()
        getgenv().RideStorm.MoneyStart = getMoney()
        moneyLabel:Set("💰 Dinero ganado: $0")
    end
})

Rayfield:Notify({
    Title = "RideStorm",
    Content = "Hub cargado correctamente",
    Duration = 4
})
