--=====================================
-- 🏍️ RideStorm Hub (ESTABLE)
--=====================================

-- 🔒 Multi-PlaceId
local SupportedPlaces = {
    [game.PlaceId] = true
}
if not SupportedPlaces[game.PlaceId] then return end

-- 📦 Servicios
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local PhysicsService = game:GetService("PhysicsService")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer

-- 🌐 Rayfield (OFICIAL)
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- 🪟 Ventana
local Window = Rayfield:CreateWindow({
    Name = "RideStorm 🏍️",
    LoadingTitle = "RideStorm",
    LoadingSubtitle = "By GaboGC",
    ConfigurationSaving = { Enabled = false }
})

-- 📑 Tabs
local DeliveryTab = Window:CreateTab("🚚 Delivery")
local TeleportTab = Window:CreateTab("📍 Teleports")
local PlayerTab   = Window:CreateTab("👤 Player")
local MiscTab     = Window:CreateTab("🎲 Misc")

-- 🌍 Estado global
getgenv().RideStorm = {
    Farming = false,
    MoneyGained = 0,
    LastMoney = 0,
    Noclip = false
}

--=====================================
-- 💰 CONTADOR REAL DE DINERO
--=====================================
local function getMoney()
    local stats = player:FindFirstChild("leaderstats")
    if not stats then return 0 end
    local money = stats:FindFirstChildWhichIsA("IntValue")
    return money and money.Value or 0
end

local moneyLabel

local function hookMoney()
    getgenv().RideStorm.LastMoney = getMoney()
    getgenv().RideStorm.MoneyGained = 0
    moneyLabel:Set("💰 Dinero ganado: $0")
end

task.spawn(function()
    while task.wait(1) do
        local current = getMoney()
        local last = getgenv().RideStorm.LastMoney
        if current > last then
            getgenv().RideStorm.MoneyGained += (current - last)
            moneyLabel:Set("💰 Dinero ganado: $" .. getgenv().RideStorm.MoneyGained)
        end
        getgenv().RideStorm.LastMoney = current
    end
end)

--=====================================
-- 🚚 DELIVERY UI
--=====================================
DeliveryTab:CreateSection("⚙️ Control")

DeliveryTab:CreateToggle({
    Name = "🚚 Auto Delivery Farm",
    CurrentValue = false,
    Callback = function(state)
        getgenv().RideStorm.Farming = state
        if state then
            teleportTo("JOB1")
            task.wait(1.5)
            loadstring(game:HttpGet(
                "https://raw.githubusercontent.com/GaboGC-hub/ride-storm/main/autofarm.lua"
            ))()
        end
    end
})

DeliveryTab:CreateSection("💰 Ganancias")

moneyLabel = DeliveryTab:CreateLabel("💰 Dinero ganado: $0")

DeliveryTab:CreateButton({
    Name = "🔄 Reiniciar contador",
    Callback = hookMoney
})

hookMoney()

--=====================================
-- 📍 TELEPORTS
--=====================================
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

local selectedMap

TeleportTab:CreateDropdown({
    Name = "Seleccionar mapa",
    Options = (function()
        local t = {}
        for _, v in ipairs(Teleports) do table.insert(t, v[1]) end
        return t
    end)(),
    CurrentOption = {},
    Callback = function(opt)
        selectedMap = opt[1]
    end
})

function teleportTo(mapName)
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")

    local map = workspace:FindFirstChild(mapName)
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
        hrp.CFrame = part.CFrame + Vector3.new(0, 5, 0)
    end
end

TeleportTab:CreateButton({
    Name = "📍 Teletransportarse",
    Callback = function()
        for _, v in ipairs(Teleports) do
            if v[1] == selectedMap then
                teleportTo(v[2])
                break
            end
        end
    end
})

--=====================================
-- 👤 PLAYER (NOCLIP REAL)
--=====================================
PlayerTab:CreateSection("Movimiento")

-- Crear grupo sin colisión con jugadores
pcall(function()
    PhysicsService:CreateCollisionGroup("RideStormNoclip")
end)
PhysicsService:CollisionGroupSetCollidable("RideStormNoclip", "Default", false)

local function setNoclip(state)
    getgenv().RideStorm.Noclip = state
end

RunService.Stepped:Connect(function()
    if not getgenv().RideStorm.Noclip then return end
    local char = player.Character
    if not char then return end

    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
            pcall(function()
                PhysicsService:SetPartCollisionGroup(part, "RideStormNoclip")
            end)
        end
    end
end)

PlayerTab:CreateToggle({
    Name = "🚫 Noclip (no empuja jugadores)",
    CurrentValue = false,
    Callback = setNoclip
})

--=====================================
-- 🎲 MISC
--=====================================
MiscTab:CreateSection("Utilidades")

-- 💤 Anti-AFK
MiscTab:CreateToggle({
    Name = "🛡️ Anti AFK",
    CurrentValue = true,
    Callback = function(state)
        if state then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end
    end
})

--=====================================
-- 🔔 NOTIFY
--=====================================
Rayfield:Notify({
    Title = "RideStorm",
    Content = "Hub cargado correctamente",
    Duration = 4
})
