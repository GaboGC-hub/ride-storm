-- main.lua (RideStorm - UI limpia y funcional)
if getgenv().RideStormLoaded then return end
getgenv().RideStormLoaded = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local player = Players.LocalPlayer

-- Safe load de módulos HTTP
local function safeLoad(url)
    local ok, res = pcall(function() return game:HttpGet(url) end)
    if not ok or not res or res:match("^%s*$") or res:match("^<!DOCTYPE") then
        warn("RideStorm: safeLoad failed -> " .. tostring(url))
        return false
    end
    local ok2, err = pcall(function() loadstring(res)() end)
    if not ok2 then
        warn("RideStorm: module execution failed ->", err)
        return false
    end
    return true
end

-- Cargar Rayfield
local Rayfield_ok, Rayfield = pcall(function()
    return loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
end)
if not Rayfield_ok or type(Rayfield) ~= "table" then
    warn("RideStorm: no se pudo cargar Rayfield. Abortando.")
    return
end

-- Crear ventana
local Window = Rayfield:CreateWindow({
    Name = "RideStorm 🏍️",
    LoadingTitle = "RideStorm",
    LoadingSubtitle = "by GaboGC",
    ConfigurationSaving = { Enabled = false }
})

-- Crear tabs
local DeliveryTab = Window:CreateTab("🚚 Delivery")
local TeleportTab = Window:CreateTab("📍 Teleports")
local PlayerTab   = Window:CreateTab("👤 Player")
local MiscTab     = Window:CreateTab("🎲 Misc")

-- Crear secciones + divisores
-- Delivery
DeliveryTab:CreateSection("📦 Auto Delivery")
DeliveryTab:CreateDivider()
DeliveryTab:CreateSection("🏍️ Speed Farm")
DeliveryTab:CreateDivider()
DeliveryTab:CreateSection("💰 Ganancias")

-- Teleports
TeleportTab:CreateSection("Teleports")
-- Player
PlayerTab:CreateSection("Movimiento")
-- Misc
MiscTab:CreateSection("Utilidades")

-- Global storage
getgenv().RideStorm = getgenv().RideStorm or {}
local RS = getgenv().RideStorm
RS.BoxFarm = RS.BoxFarm or false
RS.SpeedFarm = RS.SpeedFarm or false
RS.SpeedKMH = RS.SpeedKMH or 120
RS._loaded = RS._loaded or {}

--------------------------
-- MONEY TRACKER
--------------------------
local moneyLabel = DeliveryTab:CreateLabel("💰 Dinero ganado: $0")
local baseCash = nil

local function hookMoney()
    local stats = player:FindFirstChild("leaderstats")
    if not stats then return false end
    local cash = stats:FindFirstChild("Cash") or stats:FindFirstChild("cash") or stats:FindFirstChild("Money")
    if not cash then return false end

    baseCash = cash.Value
    moneyLabel:Set("💰 Dinero ganado: $0")

    cash:GetPropertyChangedSignal("Value"):Connect(function()
        local gained = cash.Value - (baseCash or 0)
        if gained < 0 then gained = 0 end
        moneyLabel:Set("💰 Dinero ganado: $" .. tostring(gained))
    end)
    return true
end

task.spawn(function()
    if not hookMoney() then
        player.CharacterAdded:Connect(function()
            task.wait(1.0)
            pcall(hookMoney)
        end)
    end
end)

--------------------------
-- TELEPORT FUNCTION
--------------------------
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

local selectedMap = "Spawn"

local function teleportTo(workspaceName)
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart", 5)
    local map = workspace:FindFirstChild(workspaceName)
    if not map then
        Rayfield:Notify({Title = "RideStorm", Content = "Mapa no cargado: "..workspaceName, Duration = 3})
        return
    end
    local part = map:FindFirstChildWhichIsA("BasePart", true)
    if part and hrp then
        hrp.CFrame = part.CFrame + Vector3.new(0,6,0)
    end
end

TeleportTab:CreateDropdown({
    Name = "Selecciona un mapa",
    Options = (function() local t={} for _,v in ipairs(Teleports) do table.insert(t,v[1]) end return t end)(),
    CurrentOption = "Spawn",
    Callback = function(option)
        selectedMap = option
    end
})

TeleportTab:CreateButton({
    Name = "📍 Teleport",
    Callback = function()
        for _, t in ipairs(Teleports) do
            if t[1] == selectedMap then
                teleportTo(t[2])
            end
        end
    end
})

--------------------------
-- AUTOFARM CAJAS
--------------------------
local function startAutofarm()
    getgenv().RideStorm.Farming = true

    local player = game.Players.LocalPlayer
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")

    local pickupBox = workspace.DeliveryJob.BoxPickingJob.PickupBox
    local pickupPrompt = pickupBox:WaitForChild("PickupPrompt")

    local jobPart = workspace.DeliveryJob.BoxPickingJob.Job.Part
    local jobPrompt = jobPart:WaitForChild("ProximityPrompt")

    -- Re-hook on respawn
    player.CharacterAdded:Connect(function(char)
        hrp = char:WaitForChild("HumanoidRootPart")
    end)

    task.spawn(function()
        while RS.Farming do
            if not hrp or not pickupPrompt or not jobPrompt then task.wait(0.5) continue end
            -- recoger
            hrp.CFrame = pickupBox.CFrame + Vector3.new(0,5,0)
            task.wait(0.15)
            fireproximityprompt(pickupPrompt, 1)
            -- entregar
            hrp.CFrame = jobPart.CFrame + Vector3.new(0,5,0)
            task.wait(0.15)
            fireproximityprompt(jobPrompt, 1)
            -- dinero estimado
            if RS.UpdateMoney then RS.UpdateMoney(100) end
            task.wait(math.random(8,15)/100)
        end
    end)
end

DeliveryTab:CreateToggle({
    Name = "📦 Auto Delivery (Cajas)",
    CurrentValue = false,
    Callback = function(v)
        RS.BoxFarm = v
        RS.Farming = v
        teleportTo("JOB1")
        if v then
            safeLoad("https://raw.githubusercontent.com/GaboGC-hub/ride-storm/main/autofarm.lua")
            startAutofarm()
        end
    end
})

--------------------------
-- SPEED FARM
--------------------------
DeliveryTab:CreateSlider({
    Name = "Velocidad simulada (km/h)",
    Range = {70, 350},
    Increment = 5,
    Suffix = "km/h",
    CurrentValue = RS.SpeedKMH,
    Callback = function(v) RS.SpeedKMH = v end
})

DeliveryTab:CreateToggle({
    Name = "🏍️ Speed Farm (Seguro)",
    CurrentValue = RS.SpeedFarm,
    Callback = function(v)
        RS.SpeedFarm = v
        if v and not RS._loaded.speedfarm then
            local ok = safeLoad("https://raw.githubusercontent.com/GaboGC-hub/ride-storm/main/speedfarm.lua")
            if ok then RS._loaded.speedfarm = true end
        end
        if RS.SpeedFarm then
            if RS.StartSeatSpeedFarm then RS.StartSeatSpeedFarm() end
        else
            if RS.StopSeatSpeedFarm then RS.StopSeatSpeedFarm() end
        end
    end
})

--------------------------
-- PLAYER UTILITIES
--------------------------
PlayerTab:CreateToggle({
    Name = "Noclip (solo tu personaje)",
    CurrentValue = false,
    Callback = function(v)
        if v then
            RS._noclipConn = RunService.Heartbeat:Connect(function()
                local c = player.Character
                if not c then return end
                for _, p in ipairs(c:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end)
        else
            if RS._noclipConn then RS._noclipConn:Disconnect() RS._noclipConn = nil end
        end
    end
})

--------------------------
-- MISC UTILITIES
--------------------------
MiscTab:CreateToggle({
    Name = "Anti-AFK",
    CurrentValue = true,
    Callback = function(v)
        if v then
            player.Idled:Connect(function()
                VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                task.wait(1)
                VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            end)
        end
    end
})

Rayfield:Notify({Title="RideStorm", Content="Hub cargado (UI limpia) ✅", Duration=4})
