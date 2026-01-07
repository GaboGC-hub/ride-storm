-- RideStorm Hub 🏍️ (ESTABLE + FIXES)

-- =============================
-- 🔒 MULTI PLACEID
-- =============================
local SupportedPlaces = {
    [game.PlaceId] = true
}

if not SupportedPlaces[game.PlaceId] then
    warn("RideStorm: PlaceId no soportado")
    return
end

-- =============================
-- 📦 RAYFIELD (OFICIAL)
-- =============================
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- =============================
-- 🪟 WINDOW
-- =============================
local Window = Rayfield:CreateWindow({
    Name = "RideStorm 🏍️",
    LoadingTitle = "RideStorm",
    LoadingSubtitle = "By GaboGC",
    ConfigurationSaving = { Enabled = false }
})

-- =============================
-- 📑 TABS
-- =============================
local DeliveryTab = Window:CreateTab("🚚 Delivery")
local TeleportTab = Window:CreateTab("📍 Teleports")
local MiscTab     = Window:CreateTab("🎲 Misc")

-- =============================
-- 🌍 GLOBAL STATE
-- =============================
getgenv().RideStorm = {
    Farming = false,
    Money = 0
}

-- =============================
-- 💰 MONEY TRACKER (REAL)
-- =============================
local player = game.Players.LocalPlayer
local stats = player:WaitForChild("leaderstats", 10)

local moneyLabel = DeliveryTab:CreateLabel("💰 Dinero ganado: $0")
local lastMoney = 0

if stats and stats:FindFirstChild("Money") then
    lastMoney = stats.Money.Value

    stats.Money:GetPropertyChangedSignal("Value"):Connect(function()
        local current = stats.Money.Value
        local diff = current - lastMoney
        if diff > 0 then
            getgenv().RideStorm.Money += diff
            moneyLabel:Set("💰 Dinero ganado: $" .. getgenv().RideStorm.Money)
        end
        lastMoney = current
    end)
else
    warn("RideStorm: No se encontró leaderstats.Money")
end

-- =============================
-- 📍 TELEPORT SYSTEM (BOTÓN)
-- =============================

local player = game.Players.LocalPlayer

-- Lista ordenada como tú querías
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

-- Solo nombres para el dropdown
local teleportNames = {}
for _, v in ipairs(Teleports) do
    table.insert(teleportNames, v[1])
end

-- Estado del mapa seleccionado
local selectedMapName = teleportNames[1]

-- =============================
-- 🔧 FUNCIÓN DE TP REAL
-- =============================
local function teleportToMap(workspaceName)
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")

    local map = workspace:FindFirstChild(workspaceName)

    if not map then
        Rayfield:Notify({
            Title = "RideStorm",
            Content = "Mapa no cargado aún. Acércate o reintenta.",
            Duration = 4
        })
        return
    end

    -- Buscar cualquier BasePart dentro del mapa
    local target = map:FindFirstChildWhichIsA("BasePart", true)

    if not target then
        Rayfield:Notify({
            Title = "RideStorm",
            Content = "No se encontró un punto válido en el mapa.",
            Duration = 4
        })
        return
    end

    hrp.CFrame = target.CFrame + Vector3.new(0, 6, 0)
end

-- =============================
-- 📋 DROPDOWN (SOLO SELECCIONA)
-- =============================
TeleportTab:CreateDropdown({
    Name = "Seleccionar mapa",
    Options = teleportNames,
    CurrentOption = selectedMapName,
    MultipleOptions = false,
    Callback = function(option)
        selectedMapName = option -- 🔥 guardar selección
    end
})

-- =============================
-- 🚀 BOTÓN DE TELEPORT
-- =============================
TeleportTab:CreateButton({
    Name = "Teletransportarse",
    Callback = function()
        for _, v in ipairs(Teleports) do
            if v[1] == selectedMapName then
                teleportToMap(v[2])
                break
            end
        end
    end
})



-- =============================
-- 🚚 AUTOFARM
-- =============================
DeliveryTab:CreateToggle({
    Name = "Auto Delivery Farm",
    CurrentValue = false,
    Callback = function(state)
        getgenv().RideStorm.Farming = state

        if state then
            -- 🔥 SI NO ESTÁ EL JOB → TP PRIMERO
            if not workspace:FindFirstChild("JOB1") then
                teleportToMap("JOB1")
                task.wait(2)
            end

            loadstring(game:HttpGet(
                "https://raw.githubusercontent.com/GaboGC-hub/ride-storm/main/autofarm.lua"
            ))()
        end
    end
})

-- =============================
-- 🎲 MISC
-- =============================
MiscTab:CreateButton({
    Name = "Reiniciar contador",
    Callback = function()
        getgenv().RideStorm.Money = 0
        moneyLabel:Set("💰 Dinero ganado: $0")
    end
})

-- =============================
-- 🔔 NOTIFY
-- =============================
Rayfield:Notify({
    Title = "RideStorm",
    Content = "Hub cargado correctamente",
    Duration = 4
})
