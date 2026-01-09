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
    local hrp = char:WaitForChild("HumanoidRootPart")

    local map = workspace:FindFirstChild(workspaceName)
    if not map then
        Rayfield:Notify({
            Title = "RideStorm",
            Content = "Mapa no cargado",
            Duration = 3
        })
        return
    end

    local part
    for _, v in ipairs(map:GetDescendants()) do
        if v:IsA("BasePart") then
            part = v
            break
        end
    end

    if part then
        hrp.CFrame = part.CFrame + Vector3.new(0,10,0)
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
DeliveryTab:CreateSection("📦 Auto Delivery")
DeliveryTab:CreateToggle({
    Name = "📦 Auto Delivery (Cajas)",
    CurrentValue = false,
    Callback = function(v)
        RS.Farming = v

        if v then
            teleportTo("JOB1")

            if not RS._loaded.autofarm then
                safeLoad("https://raw.githubusercontent.com/GaboGC-hub/ride-storm/main/autofarm.lua")
                RS._loaded.autofarm = true
            end
        end
    end
})
DeliveryTab:CreateDivider()

--------------------------
-- SPEED FARM
--------------------------
DeliveryTab:CreateSection("🏍️ Speed Farm")
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
DeliveryTab:CreateDivider()

--------------------------
-- MONEY TRACKER
--------------------------
DeliveryTab:CreateSection("💰 Ganancias")
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
-- PLAYER UTILITIES
--------------------------
PlayerTab:CreateToggle({
    Name = "Noclip (estable)",
    CurrentValue = false,
    Callback = function(v)
        if v then
            RS._noclipConn = RunService.Stepped:Connect(function()
                local char = player.Character
                if not char then return end
                for _, p in ipairs(char:GetChildren()) do
                    if p:IsA("BasePart") then
                        p.CanCollide = false
                        p.AssemblyLinearVelocity = Vector3.zero
                    end
                end
            end)
        else
            if RS._noclipConn then
                RS._noclipConn:Disconnect()
                RS._noclipConn = nil
            end
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
