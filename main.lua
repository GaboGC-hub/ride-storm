-- RideStorm Hub (ESTABLE)

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Rayfield OFICIAL
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- Window
local Window = Rayfield:CreateWindow({
    Name = "RideStorm 🏍️",
    LoadingTitle = "RideStorm",
    LoadingSubtitle = "By GaboGC",
    ConfigurationSaving = { Enabled = false }
})

-- Tabs
local DeliveryTab = Window:CreateTab("🚚 Delivery")
local TeleportTab = Window:CreateTab("📍 Teleports")
local MiscTab = Window:CreateTab("⚙️ Misc")

-- Global State
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
    -- ⚠️ AJUSTA ESTE PATH AL REAL DEL JUEGO
    local stats = player:FindFirstChild("leaderstats")
    if stats and stats:FindFirstChild("Money") then
        return stats.Money.Value
    end
    return 0
end

getgenv().RideStorm.MoneyStart = getMoney()

local moneyLabel = DeliveryTab:CreateLabel("💰 Dinero ganado: $0")

task.spawn(function()
    while task.wait(0.5) do
        local current = getMoney()
        getgenv().RideStorm.MoneyCurrent = current
        local gained = current - getgenv().RideStorm.MoneyStart
        moneyLabel:Set("💰 Dinero ganado: $" .. math.max(gained, 0))
    end
end)

------------------------------------------------
-- 🚚 AUTOFARM CAJAS (NO TOCAR, FUNCIONA)
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
-- 🏍️ SPEED FARM
------------------------------------------------
DeliveryTab:CreateToggle({
    Name = "🏍️ Speed Farm (Moto)",
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
-- 📍 TELEPORTS (BOTONES, NO DROPDOWN)
------------------------------------------------
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

local function tpTo(workspaceName)
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")

    local map = workspace:FindFirstChild(workspaceName)
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
        hrp.CFrame = part.CFrame + Vector3.new(0, 6, 0)
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
-- ⚙️ MISC
------------------------------------------------
MiscTab:CreateToggle({
    Name = "🛑 Anti-AFK",
    CurrentValue = true,
    Callback = function(v)
        if v then
            local vu = game:GetService("VirtualUser")
            player.Idled:Connect(function()
                vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                task.wait(1)
                vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            end)
        end
    end
})

Rayfield:Notify({
    Title = "RideStorm",
    Content = "Hub cargado correctamente",
    Duration = 4
})
