-- =============================
-- RideStorm Hub 🏍️ FINAL
-- =============================

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "RideStorm 🏍️",
    LoadingTitle = "RideStorm",
    LoadingSubtitle = "By GaboGC",
    ConfigurationSaving = { Enabled = false }
})

-- Tabs (FORMA CORRECTA)
local DeliveryTab = Window:CreateTab("🚚 Delivery")
local TeleportTab = Window:CreateTab("📍 Teleports")
local PlayerTab   = Window:CreateTab("👤 Player")
local MiscTab     = Window:CreateTab("🎲 Misc")

-- Secciones
DeliveryTab:CreateSection("Auto Farm")
DeliveryTab:CreateSection("Ganancias")
TeleportTab:CreateSection("Mapas")
PlayerTab:CreateSection("Jugador")
MiscTab:CreateSection("Utilidades")

-- Estado global
getgenv().RideStorm = {
    BoxFarm = false,
    SpeedFarm = false
}

-- 💰 CONTADOR REAL
local moneyLabel = DeliveryTab:CreateLabel("💰 Dinero ganado: $0")
local startCash

task.spawn(function()
    local stats = player:WaitForChild("leaderstats", 15)
    local cash = stats and stats:WaitForChild("Cash", 15)
    if not cash then return end

    startCash = cash.Value
    cash:GetPropertyChangedSignal("Value"):Connect(function()
        local gained = cash.Value - startCash
        if gained < 0 then gained = 0 end
        moneyLabel:Set("💰 Dinero ganado: $" .. gained)
    end)
end)

-- 📦 AUTO DELIVERY (CAJAS)
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

-- 🏍️ SPEED FARM
DeliveryTab:CreateToggle({
    Name = "🏍️ Speed Farm (Alta velocidad)",
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

-- 🛡️ ANTI AFK
MiscTab:CreateToggle({
    Name = "Anti-AFK",
    CurrentValue = true,
    Callback = function(v)
        if v then
            player.Idled:Connect(function()
                VirtualUser:Button2Down(Vector2.new(), workspace.CurrentCamera.CFrame)
                task.wait(1)
                VirtualUser:Button2Up(Vector2.new(), workspace.CurrentCamera.CFrame)
            end)
        end
    end
})

Rayfield:Notify({
    Title = "RideStorm",
    Content = "Hub cargado correctamente",
    Duration = 4
})
