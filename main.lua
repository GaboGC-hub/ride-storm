-- =============================
-- RideStorm Hub 🏍️ (ESTABLE + SPEEDFARM)
-- =============================

-- Servicios
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local player = Players.LocalPlayer

-- =============================
-- RAYFIELD (OFICIAL)
-- =============================
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- =============================
-- VENTANA
-- =============================
local Window = Rayfield:CreateWindow({
    Name = "RideStorm 🏍️",
    LoadingTitle = "RideStorm",
    LoadingSubtitle = "by GaboGC",
    ConfigurationSaving = { Enabled = false }
})

-- =============================
-- TABS
-- =============================
local DeliveryTab = Window:CreateTab("🚚 Delivery")
local TeleportTab = Window:CreateTab("📍 Teleports")
local PlayerTab   = Window:CreateTab("👤 Player")
local MiscTab     = Window:CreateTab("⚙️ Misc")

-- =============================
-- SECTIONS
-- =============================
DeliveryTab:CreateSection("🚚 Auto Delivery")
DeliveryTab:CreateSection("🏍️ Speed Farm")
DeliveryTab:CreateSection("💰 Ganancias")

TeleportTab:CreateSection("🗺️ Mapas")
PlayerTab:CreateSection("🧍 Movimiento")
MiscTab:CreateSection("🛠️ Utilidades")

-- =============================
-- 🌍 TELEPORT BASE
-- =============================
local function teleportTo(workspaceName)
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")

    local map = workspace:FindFirstChild(workspaceName)
    if not map then
        Rayfield:Notify({
            Title = "RideStorm",
            Content = "Mapa no cargado (Streaming)",
            Duration = 3
        })
        return false
    end

    local part = map:FindFirstChildWhichIsA("BasePart", true)
    if part then
        hrp.CFrame = part.CFrame + Vector3.new(0, 6, 0)
        return true
    end
    return false
end

-- =============================
-- 💰 CONTADOR DE DINERO REAL
-- =============================
local moneyLabel = DeliveryTab:CreateLabel("💰 Dinero ganado: $0")
local baseMoney = 0

local function hookMoney()
    local stats = player:WaitForChild("leaderstats", 10)
    if not stats then return end

    local money =
        stats:FindFirstChild("Money")
        or stats:FindFirstChild("Cash")
        or stats:FindFirstChild("Coins")

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
-- 🚚 AUTO DELIVERY (CAJAS)
-- =============================
getgenv().RideStorm = getgenv().RideStorm or {}
getgenv().RideStorm.Farming = false
getgenv().RideStorm.SpeedFarm = false

DeliveryTab:CreateToggle({
    Name = "📦 Auto Delivery (Cajas)",
    CurrentValue = false,
    Callback = function(state)
        getgenv().RideStorm.Farming = state
        if state then
            teleportTo("JOB1") -- 🔥 FIX IMPORTANTE
            task.wait(1.5)
            loadstring(game:HttpGet(
                "https://raw.githubusercontent.com/GaboGC-hub/ride-storm/main/autofarm.lua"
            ))()
        end
    end
})

-- =============================
-- 🏍️ SPEED FARM (300 STUDS/S)
-- =============================
local SPEED = 300

RunService.Heartbeat:Connect(function()
    if not getgenv().RideStorm.SpeedFarm then return end

    local char = player.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or not hum.SeatPart then return end

    local root = hum.SeatPart.Parent.PrimaryPart or hum.SeatPart
    if not root then return end

    local dir = root.CFrame.LookVector

    root.AssemblyLinearVelocity = Vector3.new(
        dir.X * SPEED,
        root.AssemblyLinearVelocity.Y,
        dir.Z * SPEED
    )

    root.AssemblyAngularVelocity = Vector3.zero
end)

DeliveryTab:CreateToggle({
    Name = "🏍️ Speed Farm (300 studs/s)",
    CurrentValue = false,
    Callback = function(state)
        getgenv().RideStorm.SpeedFarm = state
    end
})

-- =============================
-- 📍 TELEPORTS
-- =============================
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

for _, v in ipairs(Teleports) do
    TeleportTab:CreateButton({
        Name = v[1],
        Callback = function()
            teleportTo(v[2])
        end
    })
end

-- =============================
-- 🛡️ ANTI-AFK
-- =============================
local antiAfkConn
MiscTab:CreateToggle({
    Name = "🛑 Anti-AFK",
    CurrentValue = false,
    Callback = function(state)
        if state then
            antiAfkConn = player.Idled:Connect(function()
                VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                task.wait(1)
                VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            end)
        else
            if antiAfkConn then antiAfkConn:Disconnect() end
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
