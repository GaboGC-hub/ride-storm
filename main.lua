-- main.lua (RideStorm - estable)
-- Reemplaza tu main.lua por este

-- Prevent double-exec
if getgenv().RideStormLoaded then return end
getgenv().RideStormLoaded = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local player = Players.LocalPlayer

-- safe wrapper for http loads (returns true on success)
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

-- Rayfield (oficial)
local Rayfield_ok, Rayfield = pcall(function()
    return loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
end)
if not Rayfield_ok or type(Rayfield) ~= "table" then
    warn("RideStorm: no se pudo cargar Rayfield. Abortando.")
    return
end

-- Create window (Rayfield expects strings for CreateTab)
local Window = Rayfield:CreateWindow({
    Name = "RideStorm 🏍️",
    LoadingTitle = "RideStorm",
    LoadingSubtitle = "by GaboGC",
    ConfigurationSaving = { Enabled = false }
})

-- Tabs (correct API usage)
local DeliveryTab = Window:CreateTab("🚚 Delivery")
local TeleportTab = Window:CreateTab("📍 Teleports")
local PlayerTab   = Window:CreateTab("👤 Player")
local MiscTab     = Window:CreateTab("🎲 Misc")

-- Sections (correct API usage)
DeliveryTab:CreateSection("Auto Delivery")
DeliveryTab:CreateSection("Speed Farm")
DeliveryTab:CreateSection("Ganancias")

TeleportTab:CreateSection("Mapas")
PlayerTab:CreateSection("Movimiento")
MiscTab:CreateSection("Utilidades")

-- Ensure global storage (do NOT overwrite if exists)
getgenv().RideStorm = getgenv().RideStorm or {}
local RS = getgenv().RideStorm

-- Fields we need (create only if missing)
RS.BoxFarm = RS.BoxFarm or false
RS.SpeedFarm = RS.SpeedFarm or false
RS.SpeedKMH = RS.SpeedKMH or 120
RS._loaded = RS._loaded or {}

-- MONEY TRACKER (robusto con re-hook on respawn)
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

-- Hook now and when character spawn (leaderstats can re-appear)
task.spawn(function()
    if not hookMoney() then
        -- wait for leaderstats if not present
        player.CharacterAdded:Connect(function()
            task.wait(1.0)
            pcall(hookMoney)
        end)
    end
end)

-- TELEPORTS (buttons)
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
        hrp.CFrame = part.CFrame + Vector3.new(0, 6, 0)
    end
end

for _, t in ipairs(Teleports) do
    TeleportTab:CreateButton({
        Name = t[1],
        Callback = function() teleportTo(t[2]) end
    })
end

------------------------------------------------
-- 🚚 AUTOFARM CAJAS (NO TOCAR, FUNCIONA)
------------------------------------------------
DeliveryTab:CreateToggle({
    Name = "📦 Auto Delivery (Cajas)",
    CurrentValue = false,
    Callback = function(v)
        getgenv().RideStorm.BoxFarm = v
        teleportTo(JOB1)
        if v then
            loadstring(game:HttpGet(
                "https://raw.githubusercontent.com/GaboGC-hub/ride-storm/main/autofarm.lua"
            ))()
        end
    end


-- SPEED FARM integration: DOES NOT overwrite RS table and uses local module
DeliveryTab:CreateSection("Speed Farm (Seguro)")
DeliveryTab:CreateSlider({
    Name = "Velocidad simulada (km/h)",
    Range = {70, 350},
    Increment = 5,
    Suffix = "km/h",
    CurrentValue = RS.SpeedKMH or 120,
    Callback = function(v)
        RS.SpeedKMH = v
    end
})

DeliveryTab:CreateToggle({
    Name = "🏍️ Speed Farm (Seguro)",
    CurrentValue = RS.SpeedFarm or false,
    Callback = function(v)
        RS.SpeedFarm = v
        if v and not RS._loaded.speedfarm then
            local ok = safeLoad("https://raw.githubusercontent.com/GaboGC-hub/ride-storm/main/speedfarm.lua")
            if ok then RS._loaded.speedfarm = true end
        end
        -- speedfarm.lua will watch RS.SpeedFarm and RS.SpeedKMH
    end
})

-- Player utilities
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

-- Anti-AFK
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

Rayfield:Notify({Title="RideStorm", Content="Hub cargado (estable) ✅", Duration=4})
