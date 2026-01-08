-- =============================
-- RideStorm Hub 🏍️ (MEJORADO)
-- =============================

-- Servicios
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local player = Players.LocalPlayer

-- =============================
-- CARGAR RAYFIELD (OFICIAL)
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
-- TABS + SECTIONS
-- =============================
local DeliveryTab = Window:CreateTab("🚚 Delivery")
local TeleportTab = Window:CreateTab("📍 Teleports")
local PlayerTab   = Window:CreateTab("👤 Player")
local MiscTab     = Window:CreateTab("🎲 Misc")

DeliveryTab:CreateSection("Auto Delivery")
DeliveryTab:CreateSection("Ganancias")

TeleportTab:CreateSection("Mapas")
PlayerTab:CreateSection("Movimiento")
MiscTab:CreateSection("Utilidades")

-- =============================
-- 💰 CONTADOR DE DINERO GANADO
-- =============================
local moneyLabel = DeliveryTab:CreateLabel("💰 Dinero ganado: $0")
local baseMoney = nil
local gained = 0

local function hookMoney()
    local leaderstats = player:WaitForChild("leaderstats", 10)
    if not leaderstats then
        moneyLabel:Set("💰 Dinero: no encontrado")
        return
    end

    local money =
        leaderstats:FindFirstChild("Money")
        or leaderstats:FindFirstChild("Cash")
        or leaderstats:FindFirstChild("Coins")

    if not money then
        moneyLabel:Set("💰 Dinero: no encontrado")
        return
    end

    baseMoney = money.Value
    gained = 0
    moneyLabel:Set("💰 Dinero ganado: $0")

    money:GetPropertyChangedSignal("Value"):Connect(function()
        if baseMoney then
            gained = money.Value - baseMoney
            if gained < 0 then gained = 0 end
            moneyLabel:Set("💰 Dinero ganado: $" .. gained)
        end
    end)
end

task.spawn(hookMoney)

DeliveryTab:CreateButton({
    Name = "Reiniciar contador",
    Callback = function()
        hookMoney()
    end
})

-- =============================
-- 📍 TELEPORT SYSTEM
-- =============================
local Teleports = {
    {"Irish Islands",      "mapa2"},
    {"Alp Mountains",      "mapa3"},
    {"Track / Drag Strip", "mapa4"},
    {"Highway",            "mapa5"},
    {"Stello Pass",        "mapa6"},
    {"Spawn",              "mapa7"},
    {"Canyons / Route 66", "mapa8"},
    {"Sunset Beach",       "mapa9"},
    {"The Pit",            "mapa1"},
    {"Enduro Course",      "mapa10"},
    {"The States",         "mapa11"},
    {"Isle of Man TT",     "mapa12"},
    {"Vintage Islands",    "mapa13"},
    {"Truckers Bay (JOB)", "JOB1"}
}

local names = {}
for _, v in ipairs(Teleports) do table.insert(names, v[1]) end
local selectedMap = names[1]

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
        return
    end

    local part = map:FindFirstChildWhichIsA("BasePart", true)
    if part then
        hrp.CFrame = part.CFrame + Vector3.new(0, 6, 0)
    end
end

TeleportTab:CreateDropdown({
    Name = "Seleccionar mapa",
    Options = names,
    CurrentOption = { selectedMap },
    MultipleOptions = false,
    Callback = function(opt)
        selectedMap = opt[1]
    end
})

TeleportTab:CreateButton({
    Name = "Teletransportarse",
    Callback = function()
        for _, v in ipairs(Teleports) do
            if v[1] == selectedMap then
                teleportTo(v[2])
                break
            end
        end
    end
})

-- =============================
-- 🚚 AUTOFARM (SAFE)
-- =============================
getgenv().RideStorm = getgenv().RideStorm or {}
getgenv().RideStorm.Farming = false

DeliveryTab:CreateToggle({
    Name = "Auto Delivery Farm",
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

-- =============================
-- 🛡️ ANTI-AFK
-- =============================
local antiAfkConn
MiscTab:CreateToggle({
    Name = "Anti-AFK",
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
-- 🚶 NOCLIP
-- =============================
local noclip = false
local noclipConn

PlayerTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Callback = function(state)
        noclip = state
        if noclip then
            noclipConn = RunService.Heartbeat:Connect(function()
                local char = player.Character
                if char then
                    for _, v in pairs(char:GetDescendants()) do
                        if v:IsA("BasePart") then
                            v.CanCollide = false
                        end
                    end
                end
            end)
        else
            if noclipConn then noclipConn:Disconnect() end
        end
    end
})

-- =============================
-- NOTIFICACIÓN
-- =============================
Rayfield:Notify({
    Title = "RideStorm",
    Content = "Hub cargado correctamente",
    Duration = 4
})
