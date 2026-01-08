-- ==========================================
-- 🏍️ RideStorm Hub | Speed Farm + UI
-- ==========================================

-- =========================
-- SERVICES
-- =========================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()

-- =========================
-- LOAD RAYFIELD (OFICIAL)
-- =========================
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- =========================
-- WINDOW
-- =========================
local Window = Rayfield:CreateWindow({
    Name = "RideStorm 🏍️",
    LoadingTitle = "RideStorm",
    LoadingSubtitle = "Speed System",
    ConfigurationSaving = { Enabled = false }
})

-- =========================
-- TABS
-- =========================
local DeliveryTab = Window:CreateTab("🚚 Delivery")
local TeleportTab = Window:CreateTab("📍 Teleports")
local PlayerTab   = Window:CreateTab("👤 Player")
local MiscTab     = Window:CreateTab("🎲 Misc")

-- =========================
-- GLOBAL STATE
-- =========================
getgenv().RideStorm = {
    Enabled = false,
    Noclip = false,
    AntiAFK = true,
    StartMoney = nil
}
local RS = getgenv().RideStorm

-- =========================
-- MONEY (REAL)
-- =========================
local function getMoney()
    local ls = player:FindFirstChild("leaderstats")
    if not ls then return end
    return ls:FindFirstChild("Cash") or ls:FindFirstChild("Money")
end

-- =========================
-- BIKE ROOT
-- =========================
local function getBikeRoot()
    char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and hum.SeatPart then
        local bike = hum.SeatPart.Parent
        return bike.PrimaryPart or bike:FindFirstChildWhichIsA("BasePart")
    end
end

-- =========================
-- SPEED FARM CONFIG
-- =========================
-- En ESTE juego:
-- 50 studs ≈ 45 km/h
-- Objetivo ≈ 100–120 km/h

local TARGET_STUDS = 115
local ACCEL = 1.2
local MAX_DIST = 220

local origin
local dir = 1
local speed = 0
local mover

-- =========================
-- START / STOP FARM
-- =========================
local function startFarm()
    local root = getBikeRoot()
    if not root then
        Rayfield:Notify({
            Title = "RideStorm",
            Content = "Móntate en una moto primero",
            Duration = 3
        })
        return
    end

    origin = root.Position
    speed = 0

    mover = Instance.new("LinearVelocity")
    mover.MaxForce = math.huge
    mover.RelativeTo = Enum.ActuatorRelativeTo.World
    mover.Attachment0 = Instance.new("Attachment", root)
    mover.Parent = root

    local money = getMoney()
    if money then
        RS.StartMoney = money.Value
    end
end

local function stopFarm()
    if mover then
        mover:Destroy()
        mover = nil
    end
end

-- =========================
-- HEARTBEAT LOOP
-- =========================
RunService.Heartbeat:Connect(function()
    if RS.Enabled then
        if not mover then
            startFarm()
            return
        end

        local root = getBikeRoot()
        if not root then return end

        speed = math.min(TARGET_STUDS, speed + ACCEL)
        mover.VectorVelocity = root.CFrame.LookVector * speed * dir

        if (root.Position - origin).Magnitude > MAX_DIST then
            dir *= -1
            origin = root.Position
        end
    else
        stopFarm()
    end

    -- NOCLIP TOTAL
    if RS.Noclip and char then
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end
end)

-- =========================
-- ANTI AFK
-- =========================
player.Idled:Connect(function()
    if RS.AntiAFK then
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end
end)

-- =========================
-- UI – DELIVERY
-- =========================
DeliveryTab:CreateToggle({
    Name = "Auto Speed Farm",
    CurrentValue = false,
    Callback = function(v)
        RS.Enabled = v
    end
})

local moneyLabel = DeliveryTab:CreateLabel("💰 Dinero ganado: $0")

DeliveryTab:CreateButton({
    Name = "Reiniciar contador",
    Callback = function()
        local money = getMoney()
        if money then
            RS.StartMoney = money.Value
            moneyLabel:Set("💰 Dinero ganado: $0")
        end
    end
})

-- Update money label
task.spawn(function()
    while task.wait(1) do
        local money = getMoney()
        if RS.StartMoney and money then
            local gained = money.Value - RS.StartMoney
            moneyLabel:Set("💰 Dinero ganado: $" .. gained)
        end
    end
end)

-- =========================
-- TELEPORTS
-- =========================
local Teleports = {
    {"Irish Islands","mapa2"},
    {"Alp Mountains","mapa3"},
    {"Track / Drag Strip","mapa4"},
    {"Highway","mapa5"},
    {"Stello Pass","mapa6"},
    {"Spawn","mapa7"},
    {"Canyons / Route 66","mapa8"},
    {"Sunset Beach","mapa9"},
    {"The Pit","mapa1"},
    {"Enduro Course","mapa10"},
    {"The States","mapa11"},
    {"Isle of Man TT","mapa12"},
    {"Vintage Islands","mapa13"},
    {"Truckers Bay (JOB)","JOB1"}
}

local names = {}
for _, v in ipairs(Teleports) do table.insert(names, v[1]) end
local selectedMap = Teleports[1]

TeleportTab:CreateDropdown({
    Name = "Mapa",
    Options = names,
    CurrentOption = {names[1]},
    Callback = function(opt)
        for _, v in ipairs(Teleports) do
            if v[1] == opt[1] then
                selectedMap = v
                break
            end
        end
    end
})

TeleportTab:CreateButton({
    Name = "Teletransportar",
    Callback = function()
        local map = workspace:FindFirstChild(selectedMap[2])
        if not map then
            Rayfield:Notify({
                Title = "RideStorm",
                Content = "Mapa no cargado (streaming)",
                Duration = 3
            })
            return
        end

        local root = char:WaitForChild("HumanoidRootPart")
        local part = map:FindFirstChildWhichIsA("BasePart", true)
        if part then
            root.CFrame = part.CFrame + Vector3.new(0,5,0)
        end
    end
})

-- =========================
-- PLAYER TAB
-- =========================
PlayerTab:CreateToggle({
    Name = "Noclip (incluye jugadores)",
    CurrentValue = false,
    Callback = function(v)
        RS.Noclip = v
    end
})

PlayerTab:CreateToggle({
    Name = "Anti AFK",
    CurrentValue = true,
    Callback = function(v)
        RS.AntiAFK = v
    end
})

-- =========================
-- MISC
-- =========================
MiscTab:CreateButton({
    Name = "Desactivar todo",
    Callback = function()
        RS.Enabled = false
        RS.Noclip = false
    end
})

Rayfield:Notify({
    Title = "RideStorm",
    Content = "Hub cargado correctamente",
    Duration = 4
})
