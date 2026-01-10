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
local DeliveryTab = Window:CreateTab("💲 Farm")
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
-- TELEPORT SYSTEM (FIXED)
--------------------------
local TeleportMap = {
    ["Irish Islands"] = "mapa2",
    ["Alp Mountains"] = "mapa3",
    ["Track / Drag Strip"] = "mapa4",
    ["Highway"] = "mapa5",
    ["Stello Pass"] = "mapa6",
    ["Spawn"] = "mapa7",
    ["Canyons / Route 66"] = "mapa8",
    ["Sunset Beach"] = "mapa9",
    ["The Pit"] = "mapa1",
    ["Enduro Course"] = "mapa10",
    ["The States"] = "mapa11",
    ["Isle of Man TT"] = "mapa12",
    ["Vintage Islands"] = "mapa13",
    ["Truckers Bay (JOB)"] = "JOB1",
}



local selectedMapName = "Spawn"

local function getSafePart(model)
    if model.PrimaryPart then
        return model.PrimaryPart
    end
    for _, v in ipairs(model:GetDescendants()) do
        if v:IsA("BasePart") and v.Size.Magnitude > 5 then
            return v
        end
    end
end

local function teleportTo(mapName)
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")

    local map = workspace:FindFirstChild(mapName)
    if not map then
        Rayfield:Notify({
            Title = "RideStorm",
            Content = "Mapa no encontrado: "..mapName,
            Duration = 3
        })
        return
    end

    -- Prioridad de spawn
    local target =
        map:FindFirstChild("Spawn", true)
        or map:FindFirstChild("SpawnLocation", true)
        or map:FindFirstChild("Teleport", true)
        or map:FindFirstChildWhichIsA("BasePart", true)

    if not target then
        Rayfield:Notify({
            Title = "RideStorm",
            Content = "No se encontró punto de TP",
            Duration = 3
        })
        return
    end

    hrp.CFrame = target.CFrame + Vector3.new(0, 8, 0)
end


local selectedMap = "Spawn"

TeleportTab:CreateDropdown({
    Name = "Selecciona un mapa",
    Options = (function()
        local t = {}
        for k in pairs(TeleportMap) do
            table.insert(t, k)
        end
        return t
    end)(),
    CurrentOption = {"Spawn"}, -- ⚠️ OBLIGATORIO como tabla
    Callback = function(option)
        if type(option) ~= "table" or not option[1] then
            warn("Dropdown option inválida:", option)
            return
        end
        selectedMap = option[1]
    end
})



TeleportTab:CreateButton({
    Name = "📍 Teleport",
    Callback = function()
        local workspaceName = TeleportMap[selectedMap]

        if not workspaceName then
            Rayfield:Notify({
                Title = "RideStorm",
                Content = "Mapa inválido",
                Duration = 3
            })
            return
        end

        teleportTo(workspaceName)
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

--------------------------
-- MONEY TRACKER
--------------------------
DeliveryTab:CreateSection("💰 Ganancias")
local moneyLabel = DeliveryTab:CreateLabel("💰 Dinero ganado: $0")
local perMinLabel = DeliveryTab:CreateLabel("🕒 Ganancia por minuto: $0")

local baseCash = nil
local sessionStartTime = os.time()
local lastCash = 0

local function hookMoney()
    local stats = player:FindFirstChild("leaderstats")
    if not stats then return false end
    local cash = stats:FindFirstChild("Cash") or stats:FindFirstChild("cash") or stats:FindFirstChild("Money")
    if not cash then return false end

    baseCash = cash.Value
    lastCash = cash.Value
    sessionStartTime = os.time()

    local function updateLabels()
        local gained = cash.Value - baseCash
        local sessionTime = math.max(1, os.time() - sessionStartTime)
        local perMin = math.floor(gained / sessionTime * 60)
        moneyLabel:Set("💰 Dinero ganado: $" .. tostring(gained))
        perMinLabel:Set("🕒 Ganancia por minuto: $" .. tostring(perMin))
    end

    cash:GetPropertyChangedSignal("Value"):Connect(updateLabels)
    
    task.spawn(function()
        while true do
            updateLabels()
            task.wait(5)
        end
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
local NoclipConn

PlayerTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Callback = function(v)
        if not v then
            if NoclipConn then NoclipConn:Disconnect() end
            return
        end

        NoclipConn = RunService.Heartbeat:Connect(function()
            local char = player.Character
            if not char then return end

            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.CanCollide = false
                end
            end
        end)
    end
})

    

--------------------------
-- MISC UTILITIES
--------------------------
local AntiAFKConn
local cam = workspace.CurrentCamera

MiscTab:CreateToggle({
    Name = "Anti-AFK",
    CurrentValue = true,
    Callback = function(v)
        if not v then
            if AntiAFKConn then AntiAFKConn:Disconnect() end
            return
        end

        -- Evento Idle
        player.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0,0))
        end)

        -- Movimiento real cada 30s
        AntiAFKConn = task.spawn(function()
            while v do
                local char = player.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum:Move(Vector3.new(0,0,-1), true)
                    task.wait(0.1)
                    hum:Move(Vector3.zero, true)
                end
                -- pequeño movimiento de cámara
                cam.CFrame = cam.CFrame * CFrame.Angles(0, math.rad(0.5), 0)
                task.wait(30)
            end
        end)
    end
})


MiscTab:CreateButton({
   Name = "Close Hub",
   Callback = function()
       Rayfield:Destroy()
   end,
})

--------------------------
-- SESSION TIME
--------------------------
local sessionStart = os.time()
local sessionLabel = MiscTab:CreateLabel("⏱️ Sesión: 00:00")

task.spawn(function()
    while true do
        local elapsed = os.time() - sessionStart
        local min = math.floor(elapsed / 60)
        local sec = elapsed % 60
        sessionLabel:Set(
            string.format("⏱️ Sesión: %02d:%02d", min, sec)
        )
        task.wait(1)
    end
end)




Rayfield:Notify({Title="RideStorm", Content="Hub cargado ✅", Duration=4})
