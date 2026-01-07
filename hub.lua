-- RideStorm Hub (ESTABLE Y LIMPIO)

--------------------------------------------------
-- Multi-PlaceId
--------------------------------------------------
local SupportedPlaces = {
    [game.PlaceId] = true
}

if not SupportedPlaces[game.PlaceId] then
    warn("RideStorm: PlaceId no soportado")
    return
end

--------------------------------------------------
-- Rayfield (OFICIAL)
--------------------------------------------------
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

--------------------------------------------------
-- Window
--------------------------------------------------
local Window = Rayfield:CreateWindow({
    Name = "RideStorm 🏍️",
    LoadingTitle = "RideStorm",
    LoadingSubtitle = "By GaboGC",
    ConfigurationSaving = { Enabled = false }
})

--------------------------------------------------
-- Tabs
--------------------------------------------------
local DeliveryTab = Window:CreateTab("🚚 Delivery")
local TeleportTab = Window:CreateTab("📍 Teleports")
local MiscTab = Window:CreateTab("🎲 Misc")

--------------------------------------------------
-- Player & Money Tracking
--------------------------------------------------
local player = game.Players.LocalPlayer
local leaderstats = player:WaitForChild("leaderstats")
local cash = leaderstats:WaitForChild("Cash")

local lastCash = cash.Value
local earnedMoney = 0

--------------------------------------------------
-- Global State
--------------------------------------------------
getgenv().RideStorm = {
    Farming = false
}

--------------------------------------------------
-- UI: Money Label
--------------------------------------------------
local moneyLabel = DeliveryTab:CreateLabel("💰 Dinero ganado: $0")

-- Actualizar dinero REAL ganado
cash:GetPropertyChangedSignal("Value"):Connect(function()
    local newCash = cash.Value
    local diff = newCash - lastCash
    if diff > 0 then
        earnedMoney += diff
        moneyLabel:Set("💰 Dinero ganado: $" .. earnedMoney)
    end
    lastCash = newCash
end)

--------------------------------------------------
-- Auto Farm Toggle
--------------------------------------------------
DeliveryTab:CreateToggle({
    Name = "Auto Delivery Farm",
    CurrentValue = false,
    Callback = function(state)
        getgenv().RideStorm.Farming = state
        if state then
            loadstring(game:HttpGet(
                "https://raw.githubusercontent.com/GaboGC-hub/ride-storm/main/autofarm.lua"
            ))()
        end
    end
})

--------------------------------------------------
-- TELEPORTS (ORDEN TUYO, PATH EXACTO)
--------------------------------------------------
TeleportTab:CreateSection("🌍 Map Teleports")

local Teleports = {
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
    Name = "Seleccionar mapa",
    Options = teleportNames,
    CurrentOption = teleportNames[1],
    MultipleOptions = false,
    Callback = function(choice)
        local char = player.Character or player.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")

        for _, v in ipairs(Teleports) do
            if v[1] == choice then
                local map = workspace:FindFirstChild(v[2])
                if map then
                    local part = map.PrimaryPart or map:FindFirstChildWhichIsA("BasePart", true)
                    if part then
                        hrp.CFrame = part.CFrame + Vector3.new(0,3,0)
                    else
                        warn("RideStorm: mapa sin BasePart:", v[2])
                    end
                else
                    warn("RideStorm: no existe workspace." .. v[2])
                end
                break
            end
        end
    end
})

--------------------------------------------------
-- Misc
--------------------------------------------------
MiscTab:CreateButton({
    Name = "Reiniciar contador de dinero",
    Callback = function()
        earnedMoney = 0
        moneyLabel:Set("💰 Dinero ganado: $0")
    end
})

--------------------------------------------------
-- Notify
--------------------------------------------------
Rayfield:Notify({
    Title = "RideStorm",
    Content = "Hub cargado correctamente",
    Duration = 4
})
