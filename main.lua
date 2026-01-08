-- =============================
-- RideStorm Hub 🏍️ FINAL ESTABLE
-- =============================

-- Servicios
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local player = Players.LocalPlayer

-- Rayfield oficial
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- Ventana
local Window = Rayfield:CreateWindow({
    Name = "RideStorm 🏍️",
    LoadingTitle = "RideStorm",
    LoadingSubtitle = "by GaboGC",
    ConfigurationSaving = { Enabled = false }
})

-- Tabs
local DeliveryTab = Window:CreateTab("🚚 Delivery")
local TeleportTab = Window:CreateTab("📍 Teleports")
local PlayerTab   = Window:CreateTab("👤 Player")
local MiscTab     = Window:CreateTab("🎲 Misc")

-- Secciones
DeliveryTab:CreateSection("Auto Delivery")
DeliveryTab:CreateSection("Ganancias")
TeleportTab:CreateSection("Mapas")
PlayerTab:CreateSection("Movimiento")
MiscTab:CreateSection("Utilidades")

-- =============================
-- 🌐 GLOBAL STATE
-- =============================
getgenv().RideStorm = {
    Farming = false,
    SpeedFarm = false
}

-- =============================
-- 💰 MONEY TRACKER (REAL)
-- =============================
local moneyLabel = DeliveryTab:CreateLabel("💰 Dinero ganado: $0")
local baseMoney = nil

local function hookMoney()
    local stats = player:WaitForChild("leaderstats", 10)
    if not stats then return end

    local money = stats:FindFirstChild("Money")
    if not money then return end

    baseMoney = money.Value
    moneyLabel:Set("💰 Dinero ganado: $0")

    money:GetPropertyChangedSignal("Value"):Connect(function()
        local gained = money.Value - baseMoney
        if gained < 0 then gained = 0 end
        moneyLabel:Set("💰 Dinero ganado: $" .. gained)
    end)
end

task.spawn(hookMoney)

-- =============================
-- 📍 TELEPORT
-- =============================
local function teleportTo(workspaceName)
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")

    local map = workspace:FindFirstChild(workspaceName)
    if not map then return end

    local part = map:FindFirstChildWhichIsA("BasePart", true)
    if part then
        hrp.CFrame = part.CFrame + Vector3.new(0, 6, 0)
    end
end

-- =============================
-- 🚚 AUTO DELIVERY (CAJAS)
-- =============================
DeliveryTab:CreateToggle({
    Name = "📦 Auto Delivery (Cajas)",
    CurrentValue = false,
    Callback = function(v)
        getgenv().RideStorm.Farming = v
        if v then
            teleportTo("JOB1") -- fuerza carga del mapa
            task.wait(1.5)
            loadstring(game:HttpGet(
                "https://raw.githubusercontent.com/GaboGC-hub/ride-storm/main/autofarm.lua"
            ))()
        end
    end
})

-- =============================
-- ⚡ SPEED FARM (AFK / FREEZE)
-- =============================
DeliveryTab:CreateToggle({
    Name = "⚡ Speed Farm (300 studs/s)",
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

DeliveryTab:CreateToggle({
    Name = "🏍️📦 Moto + Cajas Farm",
    CurrentValue = false,
    Callback = function(v)
        getgenv().RideStorm.MotoBoxFarm = v
        if v then
            loadstring(game:HttpGet(
                "https://raw.githubusercontent.com/GaboGC-hub/ride-storm/main/delivery/moto_box_farm.lua"
            ))()
        end
    end
})


-- =============================
-- 🛡️ ANTI-AFK
-- =============================
MiscTab:CreateToggle({
    Name = "Anti-AFK",
    CurrentValue = true,
    Callback = function(v)
        if v then
            player.Idled:Connect(function()
                VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                task.wait(1)
                VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            end)
        end
    end
})

-- =============================
-- 🚶 NOCLIP (PERFECTO)
-- =============================
local noclipConn
PlayerTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Callback = function(v)
        if v then
            noclipConn = RunService.Heartbeat:Connect(function()
                local char = player.Character
                if not char then return end
                for _, p in pairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then
                        p.CanCollide = false
                    end
                end
            end)
        else
            if noclipConn then noclipConn:Disconnect() end
        end
    end
})

-- =============================
-- NOTIFY
-- =============================
Rayfield:Notify({
    Title = "RideStorm",
    Content = "Hub cargado correctamente",
    Duration = 4
})
