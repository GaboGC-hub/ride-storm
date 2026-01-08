-- RideStorm Hub (FINAL ESTABLE)

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Rayfield oficial
local Rayfield
local success, err = pcall(function()
    Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
end)

if not success or type(Rayfield) ~= "table" then
    warn("RideStorm: Rayfield no pudo cargarse")
    return
end


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
        if RS.MoneyStart then
            local gained = getMoney() - RS.MoneyStart
            moneyLabel:Set("💰 Dinero ganado: $" .. math.max(gained, 0))
        end
    end
end)

DeliveryTab:CreateButton({
    Name = "🔄 Reiniciar contador",
    Callback = function()
        RS.MoneyStart = getMoney()
    end
})

-- =============================
-- ⚙️ MISC (para que NO se desactive)
-- =============================
MiscTab:CreateSection({
    Name = "⚙️ Utilidades"
})

MiscTab:CreateToggle({
    Name = "🛑 Anti-AFK",
    CurrentValue = false,
    Callback = function(v)
        RS.AntiAFK = v
    end
})

-- Anti-AFK real
task.spawn(function()
    local vu = game:GetService("VirtualUser")
    while task.wait(30) do
        if RS.AntiAFK then
            vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        end
    end
end)

-- =============================
-- LOAD SCRIPTS ONCE
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

Rayfield:Notify({
    Title = "RideStorm",
    Content = "Hub cargado correctamente",
    Duration = 4
})
