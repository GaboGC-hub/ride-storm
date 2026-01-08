--====================================================
-- RideStorm 🏍️  (VERSIÓN ESTABLE – NO TOCAR CORE)
--====================================================

-- 🔐 PlaceId (permite todos por ahora)
local SupportedPlaces = {
    [game.PlaceId] = true
}
if not SupportedPlaces[game.PlaceId] then return end

--====================================================
-- 📦 Servicios
--====================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local player = Players.LocalPlayer

--====================================================
-- 🎨 Rayfield (OFICIAL)
--====================================================
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "RideStorm 🏍️",
    LoadingTitle = "RideStorm",
    LoadingSubtitle = "Stable Build",
    ConfigurationSaving = { Enabled = false }
})

local DeliveryTab = Window:CreateTab("🚚 Delivery")
local TeleportTab = Window:CreateTab("📍 Teleports")
local PlayerTab   = Window:CreateTab("👤 Player")
local MiscTab     = Window:CreateTab("🎲 Misc")

--====================================================
-- 🌐 Estado Global
--====================================================
getgenv().RideStorm = {
    SpeedFarm = false,
    StartMoney = 0,
    CurrentMoney = 0
}

--====================================================
-- 💰 DINERO REAL (POR DIFERENCIA)
--====================================================
local function getMoney()
    -- 🔴 AJUSTA ESTE PATH SI CAMBIA
    local stats = player:FindFirstChild("leaderstats")
    if stats and stats:FindFirstChild("Money") then
        return stats.Money.Value
    end
    return 0
end

getgenv().RideStorm.StartMoney = getMoney()

local moneyLabel = DeliveryTab:CreateLabel("💰 Dinero ganado: $0")

task.spawn(function()
    while task.wait(0.5) do
        local now = getMoney()
        getgenv().RideStorm.CurrentMoney = now - getgenv().RideStorm.StartMoney
        moneyLabel:Set("💰 Dinero ganado: $" .. getgenv().RideStorm.CurrentMoney)
    end
end)

DeliveryTab:CreateButton({
    Name = "Reiniciar contador",
    Callback = function()
        getgenv().RideStorm.StartMoney = getMoney()
    end
})

--=====================================
-- 🏍️ SPEED FARM (HIGH SPEED / AIR SAFE)
--=====================================
DeliveryTab:CreateSection("Speed Farm")

local SPEED = 65        -- 🔥 studs/s (~230 km/h)
local DIST  = 160
local dir = 1

local velObj
local gyro
local startPos

local function getVehicle()
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and hum.SeatPart then
        return hum.SeatPart.Parent
    end
end

local function prepareVehicle(veh)
    for _, p in ipairs(veh:GetDescendants()) do
        if p:IsA("BasePart") then
            p.CustomPhysicalProperties = PhysicalProperties.new(
                0.01, -- density
                0,    -- friction
                0,    -- elasticity
                0,    -- friction weight
                0     -- elasticity weight
            )
        end
    end
end

local function startSpeedFarm()
    local veh = getVehicle()
    if not veh then return end

    local root = veh.PrimaryPart or veh:FindFirstChildWhichIsA("BasePart")
    if not root then return end

    prepareVehicle(veh)
    startPos = root.Position

    -- 🔥 VELOCIDAD REAL
    velObj = Instance.new("BodyVelocity")
    velObj.MaxForce = Vector3.new(1e8, 1e8, 1e8) -- 🚀 aire incluido
    velObj.Velocity = root.CFrame.LookVector * SPEED
    velObj.P = 2e4
    velObj.Parent = root

    -- 🔒 ESTABILIZADOR (no rota)
    gyro = Instance.new("BodyGyro")
    gyro.MaxTorque = Vector3.new(1e7, 1e7, 1e7)
    gyro.CFrame = root.CFrame
    gyro.P = 1e4
    gyro.Parent = root
end

local function stopSpeedFarm()
    if velObj then velObj:Destroy() velObj = nil end
    if gyro then gyro:Destroy() gyro = nil end
end

RunService.Heartbeat:Connect(function()
    if not getgenv().RideStorm.SpeedFarm then
        stopSpeedFarm()
        return
    end

    local veh = getVehicle()
    if not veh then return end

    local root = veh.PrimaryPart or veh:FindFirstChildWhichIsA("BasePart")
    if not root or not velObj then return end

    if (root.Position - startPos).Magnitude >= DIST then
        dir *= -1
        startPos = root.Position
        velObj.Velocity = root.CFrame.LookVector * SPEED * dir
    end

    -- mantiene dirección aunque esté en el aire
    gyro.CFrame = CFrame.lookAt(
        root.Position,
        root.Position + velObj.Velocity
    )
end)

DeliveryTab:CreateToggle({
    Name = "🏍️ Speed Farm (FAST / AIR)",
    CurrentValue = false,
    Callback = function(v)
        getgenv().RideStorm.SpeedFarm = v
        if v then
            task.wait(0.15)
            startSpeedFarm()
        end
    end
})

--====================================================
-- 📍 TELEPORTS (BOTÓN + SELECCIÓN)
--====================================================
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

local selectedMap = Teleports[1]

TeleportTab:CreateDropdown({
    Name = "Seleccionar mapa",
    Options = (function()
        local t = {}
        for _, v in ipairs(Teleports) do table.insert(t, v[1]) end
        return t
    end)(),
    CurrentOption = { Teleports[1][1] },
    Callback = function(opt)
        for _, v in ipairs(Teleports) do
            if v[1] == opt[1] then
                selectedMap = v
            end
        end
    end
})

TeleportTab:CreateButton({
    Name = "📍 Teletransportar",
    Callback = function()
        local char = player.Character or player.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")

        local map = workspace:FindFirstChild(selectedMap[2])
        if not map then
            Rayfield:Notify({
                Title = "RideStorm",
                Content = "Mapa no cargado (streaming)",
                Duration = 3
            })
            return
        end

        local part = map:FindFirstChildWhichIsA("BasePart", true)
        if part then
            hrp.CFrame = part.CFrame + Vector3.new(0,5,0)
        end
    end
})

--====================================================
-- 🚫 NOCLIP (NO TOCA OTROS JUGADORES)
--====================================================
local noclip = false
PlayerTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Callback = function(v)
        noclip = v
    end
})

RunService.Stepped:Connect(function()
    if not noclip then return end
    local char = player.Character
    if not char then return end

    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end)

--====================================================
-- 💤 ANTI AFK
--====================================================
player.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

--====================================================
Rayfield:Notify({
    Title = "RideStorm",
    Content = "Hub cargado (build estable)",
    Duration = 4
})
