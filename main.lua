-- RideStorm Hub (ESTABLE + MEJORADO)

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "RideStorm 🏍️",
    LoadingTitle = "RideStorm",
    LoadingSubtitle = "By GaboGC",
    ConfigurationSaving = { Enabled = false }
})

local DeliveryTab = Window:CreateTab("🚚 Delivery")
local TeleportTab = Window:CreateTab("📍 Teleports")
local MiscTab = Window:CreateTab("⚙️ Misc")

-- =============================
-- GLOBAL STATE
-- =============================
getgenv().RideStorm = {
    BoxFarm = false,
    SpeedFarm = false,
    MoneyStart = 0,
    MoneyCurrent = 0
}

------------------------------------------------
-- 💰 MONEY TRACKER (REAL)
------------------------------------------------
local function getMoney()
    local stats = player:FindFirstChild("leaderstats")
    if stats and stats:FindFirstChild("Money") then
        return stats.Money.Value
    end
    return 0
end

getgenv().RideStorm.MoneyStart = getMoney()

DeliveryTab:CreateSection("📦 Delivery Systems")
local moneyLabel = DeliveryTab:CreateLabel("💰 Dinero ganado: $0")

task.spawn(function()
    while task.wait(0.5) do
        local current = getMoney()
        local gained = current - getgenv().RideStorm.MoneyStart
        moneyLabel:Set("💰 Dinero ganado: $" .. math.max(gained, 0))
    end
end)

------------------------------------------------
-- 📦 AUTOFARM CAJAS (NO TOCAR)
------------------------------------------------
DeliveryTab:CreateToggle({
    Name = "📦 Auto Delivery (Cajas)",
    CurrentValue = false,
    Callback = function(v)
        getgenv().RideStorm.BoxFarm = v
        if v then
            loadstring(game:HttpGet(
                "https://raw.githubusercontent.com/GaboGC-hub/ride-storm/main/autofarm.lua"
            ))()
        end
    end
})

------------------------------------------------
-- 🏍️ SPEED FARM (120+ km/h)
------------------------------------------------
DeliveryTab:CreateToggle({
    Name = "🏍️ Speed Farm (120+ km/h)",
    CurrentValue = false,
    Callback = function(v)
        getgenv().RideStorm.SpeedFarm = v
        if v then
            loadstring(game:HttpGet(
                "https://raw.githubusercontent.com/GaboGC-hub/ride-storm/main/speedfarm.lua"
            ))()
        end
    end
})

------------------------------------------------
-- 📍 TELEPORTS
------------------------------------------------
TeleportTab:CreateSection("🗺️ Maps")

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
    {"Truckers Bay (JOB)", "JOB1"},
}

local function tpTo(name)
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")

    local map = workspace:FindFirstChild(name)
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
        hrp.CFrame = part.CFrame + Vector3.new(0,6,0)
    end
end

for _, v in ipairs(Teleports) do
    TeleportTab:CreateButton({
        Name = v[1],
        Callback = function()
            tpTo(v[2])
        end
    })
end

------------------------------------------------
-- ⚙️ MISC (CARGA MODULO)
------------------------------------------------
loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/GaboGC-hub/ride-storm/main/misc.lua"
))()

Rayfield:Notify({
    Title = "RideStorm",
    Content = "Hub cargado correctamente",
    Duration = 4
})
