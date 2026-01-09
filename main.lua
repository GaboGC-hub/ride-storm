-- =====================================
-- RideStorm Hub 🏍️ FINAL LIMPIO
-- =====================================

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local player = Players.LocalPlayer

-- Rayfield oficial
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- Window
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

-- Sections
DeliveryTab:CreateSection("Auto Delivery")
DeliveryTab:CreateSection("Speed Farm")
DeliveryTab:CreateSection("Ganancias")

TeleportTab:CreateSection("Mapas")

PlayerTab:CreateSection("Movimiento")

MiscTab:CreateSection("Utilidades")

-- =====================================
-- GLOBAL STATE
-- =====================================
getgenv().RideStorm = {
    BoxFarm = false,
    SpeedFarm = false,
    SpeedKMH = 120,
    MoneyStart = 0
}
local RS = getgenv().RideStorm

-- =====================================
-- MONEY TRACKER (REAL)
-- Usa leaderstats.cash
-- =====================================
local moneyLabel = DeliveryTab:CreateLabel("💰 Dinero ganado: $0")

local function getMoney()
    local stats = player:FindFirstChild("leaderstats")
    if stats then
        local cash = stats:FindFirstChild("cash")
        if cash then
            return cash.Value
        end
    end
    return 0
end

task.spawn(function()
    while task.wait(0.5) do
        if RS.MoneyStart > 0 then
            local gained = getMoney() - RS.MoneyStart
            if gained < 0 then gained = 0 end
            moneyLabel:Set("💰 Dinero ganado: $" .. gained)
        end
    end
end)

-- =====================================
-- 📍 TELEPORT SYSTEM (ARREGLADO)
-- =====================================
local Teleports = {
    {"Irish Islands", "mapa2"},
    {"Alp Mountains", "mapa3"},
    {"Track / Drag Strip", "mapa4"},
    {"Highway", "mapa5"},
    {"Stello Pass", "mapa6"},
    {"Spawn", "mapa7"},
    {"Canyons / Route 66", "mapa8"},
    {"Sunset Beach", "mapa9"},
    {"The Pit", "mapa1"},
    {"Enduro Course", "mapa10"},
    {"The States", "mapa11"},
    {"Isle of Man TT", "mapa12"},
    {"Vintage Islands", "mapa13"},
    {"Truckers Bay (JOB)", "JOB1"}
}

local function teleportTo(workspaceName)
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")

    local map = workspace:FindFirstChild(workspaceName)
    if not map then
        Rayfield:Notify({
            Title = "RideStorm",
            Content = "Mapa no cargado aún, intenta otra vez",
            Duration = 3
        })
        return
    end

    local part = map:FindFirstChildWhichIsA("BasePart", true)
    if part then
        hrp.CFrame = part.CFrame + Vector3.new(0, 6, 0)
    end
end

-- Crear botones REALES
for _, v in ipairs(Teleports) do
    TeleportTab:CreateButton({
        Name = v[1],
        Callback = function()
            teleportTo(v[2])
        end
    })
end

-- =====================================
-- 🚚 AUTO DELIVERY (CAJAS) — FIX STREAMING
-- =====================================
DeliveryTab:CreateToggle({
    Name = "📦 Auto Delivery (Cajas)",
    CurrentValue = false,
    Callback = function(v)
        RS.BoxFarm = v
        if v then
            RS.MoneyStart = getMoney()

            -- FORZAR CARGA DEL MAPA
            teleportTo("JOB1")
            task.wait(2)

            -- Esperar a que exista DeliveryJob
            local ok = pcall(function()
                workspace:WaitForChild("DeliveryJob", 10)
            end)

            if ok then
                loadstring(game:HttpGet(
                    "https://raw.githubusercontent.com/GaboGC-hub/ride-storm/main/autofarm.lua"
                ))()
            else
                Rayfield:Notify({
                    Title = "RideStorm",
                    Content = "No se pudo cargar DeliveryJob",
                    Duration = 4
                })
            end
        end
    end
})

-- =====================================
-- 🏍️ SPEED FARM (SEAT SPOOF — BLINDADO)
-- =====================================
local function kmhToStuds(kmh)
    return kmh * 1.11 -- TU conversión real
end

local function getSeat()
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        return hum.SeatPart
    end
end

local speedConn

local function startSpeedFarm()
    if speedConn then speedConn:Disconnect() end

    speedConn = RunService.Heartbeat:Connect(function()
        if not RS.SpeedFarm then return end
        local seat = getSeat()
        if not seat then return end

        seat.AssemblyLinearVelocity =
            seat.CFrame.LookVector * kmhToStuds(RS.SpeedKMH)
    end)
end

local function stopSpeedFarm()
    if speedConn then
        speedConn:Disconnect()
        speedConn = nil
    end
end

-- Auto start / stop al sentarse
local function onCharacter(char)
    local hum = char:WaitForChild("Humanoid")
    hum.Seated:Connect(function(active)
        if active and RS.SpeedFarm then
            task.wait(0.15)
            startSpeedFarm()
        else
            stopSpeedFarm()
        end
    end)
end

if player.Character then onCharacter(player.Character) end
player.CharacterAdded:Connect(onCharacter)

DeliveryTab:CreateToggle({
    Name = "🏍️ Speed Farm (Seguro)",
    CurrentValue = false,
    Callback = function(v)
        RS.SpeedFarm = v
        if not v then stopSpeedFarm() end
    end
})

DeliveryTab:CreateSlider({
    Name = "Velocidad simulada",
    Range = {70, 350},
    Increment = 5,
    Suffix = "km/h",
    CurrentValue = RS.SpeedKMH,
    Callback = function(v)
        RS.SpeedKMH = v
    end
})

-- =====================================
-- 🛡️ ANTI-AFK
-- =====================================
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

-- =====================================
-- 🚶 NOCLIP (NO MOLESTA A OTROS)
-- =====================================
local noclipConn
PlayerTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Callback = function(v)
        if v then
            noclipConn = RunService.Heartbeat:Connect(function()
                local char = player.Character
                if not char then return end
                for _, p in ipairs(char:GetChildren()) do
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

Rayfield:Notify({
    Title = "RideStorm",
    Content = "Hub cargado correctamente ✅",
    Duration = 4
})
