--==================================================
-- RideStorm Hub 🏍️ (ESTABLE + STREAMING SAFE)
-- By GaboGC
--==================================================

----------------------------------------------------
-- Multi-PlaceId (opcional)
----------------------------------------------------
local SupportedPlaces = {
    [game.PlaceId] = true
}

if not SupportedPlaces[game.PlaceId] then
    warn("RideStorm: PlaceId no soportado")
    return
end

----------------------------------------------------
-- Rayfield (FORMA OFICIAL)
----------------------------------------------------
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

----------------------------------------------------
-- Window
----------------------------------------------------
local Window = Rayfield:CreateWindow({
    Name = "RideStorm 🏍️",
    LoadingTitle = "RideStorm",
    LoadingSubtitle = "By GaboGC",
    ConfigurationSaving = {
        Enabled = false
    }
})

----------------------------------------------------
-- Tabs
----------------------------------------------------
local DeliveryTab = Window:CreateTab("🚚 Delivery")
local TeleportTab = Window:CreateTab("📍 Teleports")
local MiscTab = Window:CreateTab("🎲 Misc")

----------------------------------------------------
-- Global State
----------------------------------------------------
getgenv().RideStorm = {
    Farming = false,
    Money = 0,
    LastMoney = 0
}

----------------------------------------------------
-- Player refs
----------------------------------------------------
local Players = game:GetService("Players")
local player = Players.LocalPlayer

----------------------------------------------------
-- SAFE TELEPORT (Streaming Compatible)
----------------------------------------------------
local function teleportToMap(mapName)
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")

    local map = workspace:WaitForChild(mapName, 10)
    if not map then
        Rayfield:Notify({
            Title = "RideStorm",
            Content = "No se pudo cargar: "..mapName,
            Duration = 4
        })
        return false
    end

    local part =
        map.PrimaryPart
        or map:FindFirstChildWhichIsA("BasePart", true)

    if not part then
        warn("RideStorm: "..mapName.." no tiene BasePart")
        return false
    end

    hrp.CFrame = part.CFrame + Vector3.new(0,5,0)
    return true
end

----------------------------------------------------
-- 💰 MONEY TRACKER REAL (NO FALSO)
----------------------------------------------------
local function setupMoneyTracker()
    local stats = player:WaitForChild("leaderstats", 10)
    if not stats then return end

    local money =
        stats:FindFirstChild("Money")
        or stats:FindFirstChild("Cash")
        or stats:FindFirstChild("Coins")

    if not money then return end

    getgenv().RideStorm.LastMoney = money.Value

    money:GetPropertyChangedSignal("Value"):Connect(function()
        local diff = money.Value - getgenv().RideStorm.LastMoney
        if diff > 0 then
            getgenv().RideStorm.Money += diff
            getgenv().RideStorm.LastMoney = money.Value
            moneyLabel:Set("💰 Dinero ganado: $"..getgenv().RideStorm.Money)
        end
    end)
end

----------------------------------------------------
-- DELIVERY UI
----------------------------------------------------
DeliveryTab:CreateSection("Auto Delivery")

local moneyLabel = DeliveryTab:CreateLabel("💰 Dinero ganado: $0")

DeliveryTab:CreateToggle({
    Name = "Auto Delivery Farm",
    CurrentValue = false,
    Callback = function(state)
        getgenv().RideStorm.Farming = state

        if state then
            -- Ir primero al mapa del trabajo
            local ok = teleportToMap("JOB1")
            if not ok then return end

            task.wait(2)

            loadstring(game:HttpGet(
                "https://raw.githubusercontent.com/GaboGC-hub/ride-storm/main/autofarm.lua"
            ))()
        end
    end
})

----------------------------------------------------
-- 📍 TELEPORTS
----------------------------------------------------
TeleportTab:CreateSection("Maps")

local Teleports = {
    { "Truckers Bay (Delivery)", "JOB1" },
    { "Irish Islands", "mapa2" },
    { "Alp Mountains", "mapa3" },
    { "Track / Drag Strip", "mapa4" },
    { "Highway", "mapa5" },
    { "Stello Pass", "mapa6" },
    { "Spawn", "mapa7" },
    { "Canyons, Route 66", "mapa8" },
    { "Sunset Beach", "mapa9" },
    { "The Pit", "mapa1" },
    { "Enduro Course", "mapa10" },
    { "The States", "mapa11" },
    { "Isle of Man TT", "mapa12" },
    { "Vintage Islands", "mapa13" }
}

local teleportNames = {}
for _, v in ipairs(Teleports) do
    table.insert(teleportNames, v[1])
end

TeleportTab:CreateDropdown({
    Name = "Seleccionar Mapa",
    Options = teleportNames,
    CurrentOption = teleportNames[1],
    Callback = function(choice)
        for _, v in ipairs(Teleports) do
            if v[1] == choice then
                teleportToMap(v[2])
                break
            end
        end
    end
})

----------------------------------------------------
-- 🎲 MISC
----------------------------------------------------
MiscTab:CreateButton({
    Name = "Reiniciar contador de dinero",
    Callback = function()
        getgenv().RideStorm.Money = 0
        moneyLabel:Set("💰 Dinero ganado: $0")
    end
})

----------------------------------------------------
-- INIT
----------------------------------------------------
task.spawn(setupMoneyTracker)

Rayfield:Notify({
    Title = "RideStorm",
    Content = "Hub cargado correctamente",
    Duration = 4
})
