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

--====================================================
-- 🏍️ SPEED FARM (CORE – NO OPTIMIZAR)
--====================================================
local SpeedFarmConnection

local function startSpeedFarm()
    if SpeedFarmConnection then return end

    SpeedFarmConnection = RunService.Heartbeat:Connect(function()
        if not getgenv().RideStorm.SpeedFarm then return end

        local char = player.Character
        if not char then return end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        -- 🔥 MOVIMIENTO REAL (esto es lo que da dinero)
        local look = hrp.CFrame.LookVector
        hrp.CFrame = hrp.CFrame + (look * 2.5) -- studs por frame
    end)
end

local function stopSpeedFarm()
    if SpeedFarmConnection then
        SpeedFarmConnection:Disconnect()
        SpeedFarmConnection = nil
    end
end

--====================================================
-- 🎚️ UI – AUTO DELIVERY ARRIBA
--====================================================
DeliveryTab:CreateToggle({
    Name = "🏍️ Auto Speed Farm",
    CurrentValue = false,
    Callback = function(v)
        getgenv().RideStorm.SpeedFarm = v
        if v then
            startSpeedFarm()
        else
            stopSpeedFarm()
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
