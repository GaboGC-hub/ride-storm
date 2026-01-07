-- =============================
-- RideStorm Hub (ESTABLE)
-- =============================

local Players = game:GetService("Players")
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
    ConfigurationSaving = {
        Enabled = false
    }
})

-- =============================
-- TABS
-- =============================
local DeliveryTab = Window:CreateTab("🚚 Delivery")
local TeleportTab = Window:CreateTab("📍 Teleports")
local MiscTab = Window:CreateTab("🎲 Misc")

-- =============================
-- SECTIONS (⚠️ OBLIGATORIO)
-- =============================
local DeliverySection = DeliveryTab:CreateSection("Auto Delivery")
local TeleportSection = TeleportTab:CreateSection("Mapas")
local MiscSection = MiscTab:CreateSection("Opciones")

-- =============================
-- 💰 CONTADOR DE DINERO REAL
-- =============================

local moneyLabel = DeliveryTab:CreateLabel("💰 Dinero: cargando...")

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

    moneyLabel:Set("💰 Dinero: $" .. money.Value)

    money:GetPropertyChangedSignal("Value"):Connect(function()
        moneyLabel:Set("💰 Dinero: $" .. money.Value)
    end)
end

task.spawn(hookMoney)

-- =============================
-- 📍 TELEPORT SYSTEM (BOTÓN)
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

local teleportNames = {}
for _, v in ipairs(Teleports) do
    table.insert(teleportNames, v[1])
end

local selectedMap = teleportNames[1]

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
    Options = teleportNames,
    CurrentOption = { selectedMap }, -- ⚠️ TABLA
    MultipleOptions = false,
    Callback = function(option)
        selectedMap = option[1]
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
-- 🚚 AUTOFARM (SAFE START)
-- =============================

getgenv().RideStorm = getgenv().RideStorm or {}
getgenv().RideStorm.Farming = false

DeliveryTab:CreateToggle({
    Name = "Auto Delivery Farm",
    CurrentValue = false,
    Callback = function(state)
        getgenv().RideStorm.Farming = state
        if state then
            teleportTo("JOB1") -- 🔥 fuerza carga del mapa
            task.wait(1.5)
            loadstring(game:HttpGet(
                "https://raw.githubusercontent.com/GaboGC-hub/ride-storm/main/autofarm.lua"
            ))()
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
