--=====================================
-- RideStorm Hub 🏍️ (ESTABLE)
--=====================================

-- 🔒 MULTI PLACE ID
local SupportedPlaces = {
    [game.PlaceId] = true
}
if not SupportedPlaces[game.PlaceId] then
    warn("RideStorm: PlaceId no soportado")
    return
end

-- 📦 SERVICIOS
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local player = Players.LocalPlayer

-- 🌐 RAYFIELD (OFICIAL)
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- 🧠 ESTADO GLOBAL
getgenv().RideStorm = {
    AutoDelivery = false,
    SpeedFarm = false,
    MoneyStart = 0,
    MoneyEarned = 0,
    SelectedTeleport = nil
}

-- 💰 PATH REAL DEL DINERO (AJUSTA SI CAMBIA)
local function getMoney()
    local stats = player:FindFirstChild("leaderstats")
    if stats then
        local cash = stats:FindFirstChild("Money") or stats:FindFirstChild("Cash")
        if cash then
            return cash.Value
        end
    end
    return 0
end

--=====================================
-- 🪟 WINDOW
--=====================================
local Window = Rayfield:CreateWindow({
    Name = "RideStorm 🏍️",
    LoadingTitle = "RideStorm",
    LoadingSubtitle = "By GaboGC",
    ConfigurationSaving = { Enabled = false }
})

local DeliveryTab = Window:CreateTab("🚚 Delivery")
local TeleportTab = Window:CreateTab("📍 Teleports")
local PlayerTab   = Window:CreateTab("🧍 Player")
local MiscTab     = Window:CreateTab("🎲 Misc")

--=====================================
-- 🚚 DELIVERY
--=====================================
DeliveryTab:CreateSection("Auto Delivery")

DeliveryTab:CreateToggle({
    Name = "🚚 Auto Delivery Farm",
    CurrentValue = false,
    Callback = function(state)
        getgenv().RideStorm.AutoDelivery = state

        if state then
            -- TP previo a Truckers Bay (streaming fix)
            local map = workspace:FindFirstChild("JOB1")
            if map then
                local part = map:FindFirstChildWhichIsA("BasePart", true)
                if part then
                    player.Character:WaitForChild("HumanoidRootPart").CFrame =
                        part.CFrame + Vector3.new(0,5,0)
                end
            end

            loadstring(game:HttpGet(
                "https://raw.githubusercontent.com/GaboGC-hub/ride-storm/main/autofarm.lua"
            ))()
        end
    end
})

local moneyLabel = DeliveryTab:CreateLabel("💰 Dinero ganado: $0")

DeliveryTab:CreateButton({
    Name = "🔄 Reiniciar contador",
    Callback = function()
        getgenv().RideStorm.MoneyStart = getMoney()
        getgenv().RideStorm.MoneyEarned = 0
        moneyLabel:Set("💰 Dinero ganado: $0")
    end
})


-- 💰 CONTADOR REAL
task.spawn(function()
    getgenv().RideStorm.MoneyStart = getMoney()
    while true do
        task.wait(0.5)
        local current = getMoney()
        local earned = current - getgenv().RideStorm.MoneyStart
        if earned >= 0 then
            getgenv().RideStorm.MoneyEarned = earned
            moneyLabel:Set("💰 Dinero ganado: $" .. earned)
        end
    end
end)

--=====================================
-- 🏍️ SPEED FARM (DINERO REAL OPTIMIZADO)
--=====================================

local SPEED_STUDS = 50 -- ≈ 180 km/h
local MAX_DIST = 140
local direction = 1
local bv
local originPos

local function getVehicleRoot()
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and hum.SeatPart then
        local veh = hum.SeatPart.Parent
        return veh.PrimaryPart or veh:FindFirstChildWhichIsA("BasePart")
    end
end

local function startSpeedFarm()
    local root = getVehicleRoot()
    if not root then
        Rayfield:Notify({
            Title = "RideStorm",
            Content = "Debes estar montado en una moto",
            Duration = 3
        })
        getgenv().RideStorm.SpeedFarm = false
        return
    end

    originPos = root.Position

    bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e6, 0, 1e6)
    bv.Velocity = root.CFrame.LookVector * SPEED_STUDS
    bv.Parent = root
end

local function stopSpeedFarm()
    if bv then
        bv:Destroy()
        bv = nil
    end
end

RunService.Heartbeat:Connect(function()
    if not getgenv().RideStorm.SpeedFarm then
        stopSpeedFarm()
        return
    end

    local root = getVehicleRoot()
    if not root or not bv then return end

    -- Mantener velocidad ALTA siempre
    bv.Velocity = root.CFrame.LookVector * SPEED_STUDS * direction

    -- Vaivén corto (anti límites / streaming)
    if (root.Position - originPos).Magnitude >= MAX_DIST then
        direction *= -1
        originPos = root.Position
    end
end)

DeliveryTab:CreateToggle({
    Name = "🏍️ Speed Farm (dinero real)",
    CurrentValue = false,
    Callback = function(v)
        getgenv().RideStorm.SpeedFarm = v
        if v then
            task.wait(0.2)
            startSpeedFarm()
        else
            stopSpeedFarm()
        end
    end
})


--=====================================
-- 📍 TELEPORTS
--=====================================
TeleportTab:CreateSection("Mapas")

local Teleports = {
    {"Irish Islands","mapa2"},
    {"Alp Mountains","mapa3"},
    {"Track / Drag Strip","mapa4"},
    {"Highway","mapa5"},
    {"Stello Pass","mapa6"},
    {"Spawn","mapa7"},
    {"Canyons / Route 66","mapa8"},
    {"Sunset Beach","mapa9"},
    {"The Pit","mapa1"},
    {"Enduro Course","mapa10"},
    {"The States","mapa11"},
    {"Isle of Man TT","mapa12"},
    {"Vintage Islands","mapa13"},
    {"Truckers Bay (JOB)","JOB1"}
}

local names = {}
for _,v in ipairs(Teleports) do table.insert(names,v[1]) end

TeleportTab:CreateDropdown({
    Name = "Seleccionar mapa",
    Options = names,
    CurrentOption = {names[1]},
    Callback = function(opt)
        getgenv().RideStorm.SelectedTeleport = opt[1]
    end
})

TeleportTab:CreateButton({
    Name = "📍 Teletransportar",
    Callback = function()
        local sel = getgenv().RideStorm.SelectedTeleport
        if not sel then return end

        for _,v in ipairs(Teleports) do
            if v[1]==sel then
                local map = workspace:FindFirstChild(v[2])
                if not map then
                    Rayfield:Notify({
                        Title="RideStorm",
                        Content="Mapa no cargado (streaming)",
                        Duration=3
                    })
                    return
                end
                local part = map:FindFirstChildWhichIsA("BasePart",true)
                if part then
                    player.Character:WaitForChild("HumanoidRootPart").CFrame =
                        part.CFrame + Vector3.new(0,5,0)
                end
            end
        end
    end
})

--=====================================
-- 🧍 PLAYER
--=====================================
PlayerTab:CreateSection("Utilidades")

-- NOCLIP (sin colisión con jugadores)
PlayerTab:CreateToggle({
    Name="Noclip",
    CurrentValue=false,
    Callback=function(v)
        RunService.Stepped:Connect(function()
            if not v then return end
            local char = player.Character
            if char then
                for _,p in ipairs(char:GetChildren()) do
                    if p:IsA("BasePart") then
                        p.CanCollide = false
                    end
                end
            end
        end)
    end
})

-- ANTI AFK
PlayerTab:CreateToggle({
    Name="Anti AFK",
    CurrentValue=false,
    Callback=function(v)
        if not v then return end
        player.Idled:Connect(function()
            VirtualUser:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
            task.wait(1)
            VirtualUser:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
        end)
    end
})

--=====================================
-- 🎲 MISC
--=====================================
MiscTab:CreateButton({
    Name="Cerrar Hub",
    Callback=function()
        Rayfield:Destroy()
    end
})

Rayfield:Notify({
    Title="RideStorm",
    Content="Hub cargado correctamente",
    Duration=4
})
