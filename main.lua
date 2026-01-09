-- main.lua (RideStorm Hub - seguro y estable)

-- Evitar doble ejecución
if getgenv().RideStormLoaded then return end
getgenv().RideStormLoaded = true

-- Servicios
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local player = Players.LocalPlayer

-- Safe loader para evitar 404 que rompan el hub
local function safeLoad(url)
    local ok, res = pcall(function() return game:HttpGet(url) end)
    if not ok or not res or res:match("^<!DOCTYPE HTML") then
        warn("RideStorm: no se pudo cargar ->", url)
        pcall(function()
            Rayfield:Notify({
                Title = "RideStorm",
                Content = "No se pudo cargar módulo (404): "..url,
                Duration = 4
            })
        end)
        return false
    end
    local ok2, err = pcall(function() loadstring(res)() end)
    if not ok2 then
        warn("RideStorm: error ejecutando módulo:", err)
        return false
    end
    return true
end

-- Cargar Rayfield con check
local Rayfield
do
    local ok, lib = pcall(function() return loadstring(game:HttpGet("https://sirius.menu/rayfield"))() end)
    if not ok or type(lib) ~= "table" then
        warn("RideStorm: Rayfield no pudo cargarse")
        return
    end
    Rayfield = lib
end

-- Ventana
local Window = Rayfield:CreateWindow({
    Name = "RideStorm 🏍️",
    LoadingTitle = "RideStorm",
    LoadingSubtitle = "by GaboGC",
    ConfigurationSaving = { Enabled = false }
})

-- Tabs (forma correcta)
local DeliveryTab = Window:CreateTab({ Name = "🚚 Delivery" })
local TeleportTab = Window:CreateTab({ Name = "📍 Teleports" })
local PlayerTab   = Window:CreateTab({ Name = "👤 Player" })
local MiscTab     = Window:CreateTab({ Name = "🎲 Misc" })

-- Secciones
DeliveryTab:CreateSection({ Name = "Auto Delivery" })
DeliveryTab:CreateSection({ Name = "Ganancias" })
TeleportTab:CreateSection({ Name = "Mapas" })
PlayerTab:CreateSection({ Name = "Movimiento" })
MiscTab:CreateSection({ Name = "Utilidades" })

-- Estado global
getgenv().RideStorm = getgenv().RideStorm or {}
local RS = getgenv().RideStorm
RS.Farming = false
RS.SpeedFarm = false
RS.MotoBoxFarm = false

-- Guardas para no cargar módulos repetidos
RS._loaded = RS._loaded or {}
RS._loaded.autofarm = RS._loaded.autofarm or false
RS._loaded.speedfarm = RS._loaded.speedfarm or false
RS._loaded.motobox = RS._loaded.motobox or false

-- ============================
-- MONEY TRACKER (leaderstats.Cash)
-- ============================
local moneyLabel = DeliveryTab:CreateLabel("💰 Dinero ganado: $0")
local baseCash = nil

-- safe wait + connect
task.spawn(function()
    local stats = player:WaitForChild("leaderstats", 15)
    if not stats then
        warn("RideStorm: leaderstats no encontrado")
        return
    end
    local cash = stats:WaitForChild("Cash", 15)
    if not cash then
        warn("RideStorm: leaderstats.Cash no encontrado")
        return
    end

    -- set baseCash if nil
    if baseCash == nil then
        baseCash = cash.Value
    end

    cash:GetPropertyChangedSignal("Value"):Connect(function()
        if baseCash == nil then baseCash = cash.Value end
        local gained = cash.Value - baseCash
        if gained < 0 then gained = 0 end
        moneyLabel:Set("💰 Dinero ganado: $" .. gained)
    end)
end)

DeliveryTab:CreateButton({
    Name = "🔄 Reiniciar contador",
    Callback = function()
        local stats = player:FindFirstChild("leaderstats")
        if not stats then return end
        local cash = stats:FindFirstChild("Cash")
        if not cash then return end
        baseCash = cash.Value
        moneyLabel:Set("💰 Dinero ganado: $0")
    end
})

-- ============================
-- Teleport seguro (si estás en moto mueve el vehículo, si no mueve HRP)
-- ============================
local function getVehicleModel()
    local char = player.Character
    if not char then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and hum.SeatPart and hum.SeatPart:IsA("VehicleSeat") then
        return hum.SeatPart:FindFirstAncestorOfClass("Model") or hum.SeatPart.Parent
    end
    return nil
end

local function safeTeleportToWorkspaceName(workspaceName)
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart", 5)

    local map = workspace:FindFirstChild(workspaceName)
    if not map then
        Rayfield:Notify({ Title = "RideStorm", Content = "Mapa no cargado (streaming): "..workspaceName, Duration = 3 })
        return
    end

    local target = map:FindFirstChildWhichIsA("BasePart", true)
    if not target then
        Rayfield:Notify({ Title = "RideStorm", Content = "No se encontró part en "..workspaceName, Duration = 3 })
        return
    end

    local veh = getVehicleModel()
    if veh and veh.PrimaryPart then
        pcall(function()
            -- freeze tiny momento
            for _, p in ipairs(veh:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.AssemblyLinearVelocity = Vector3.zero
                    p.AssemblyAngularVelocity = Vector3.zero
                end
            end
            veh:SetPrimaryPartCFrame(target.CFrame + Vector3.new(0,6,0))
        end)
    else
        if hrp then
            hrp.CFrame = target.CFrame + Vector3.new(0,6,0)
        end
    end
end

-- Teleports table (diccionario)
local Teleports = {
    {Name = "Irish Islands", Path = "mapa2"},
    {Name = "Alp Mountains", Path = "mapa3"},
    {Name = "Track / Drag Strip", Path = "mapa4"},
    {Name = "Highway", Path = "mapa5"},
    {Name = "Stello Pass", Path = "mapa6"},
    {Name = "Spawn", Path = "mapa7"},
    {Name = "Canyons / Route 66", Path = "mapa8"},
    {Name = "Sunset Beach", Path = "mapa9"},
    {Name = "The Pit", Path = "mapa1"},
    {Name = "Enduro Course", Path = "mapa10"},
    {Name = "The States", Path = "mapa11"},
    {Name = "Isle of Man TT", Path = "mapa12"},
    {Name = "Vintage Islands", Path = "mapa13"},
    {Name = "Truckers Bay (JOB)", Path = "JOB1"},
}

-- crear botones de teleports
for _, tp in ipairs(Teleports) do
    TeleportTab:CreateButton({
        Name = tp.Name,
        Callback = function()
            safeTeleportToWorkspaceName(tp.Path)
        end
    })
end

-- ============================
-- AUTO DELIVERY (cajas) toggle (carga una vez)
-- ============================
DeliveryTab:CreateToggle({
    Name = "📦 Auto Delivery (Cajas)",
    CurrentValue = false,
    Callback = function(v)
        RS.Farming = v
        if v then
            safeTeleportToWorkspaceName("JOB1")
            task.wait(1.2)
            if not RS._loaded.autofarm then
                RS._loaded.autofarm = safeLoad("https://raw.githubusercontent.com/GaboGC-hub/ride-storm/main/autofarm.lua")
            end
        end
    end
})

-- ============================
-- SPEED FARM toggle (carga una vez)
-- ============================
DeliveryTab:CreateToggle({
    Name = "🏍️ Speed Farm (optimizado)",
    CurrentValue = false,
    Callback = function(v)
        RS.SpeedFarm = v
        if v then
            if not RS._loaded.speedfarm then
                RS._loaded.speedfarm = safeLoad("https://raw.githubusercontent.com/GaboGC-hub/ride-storm/main/speedfarm.lua")
            end
        end
    end
})

-- ============================
-- Moto + cajas farm toggle (carga una vez)
-- ============================
DeliveryTab:CreateToggle({
    Name = "🏍️📦 Moto + Cajas Farm",
    CurrentValue = false,
    Callback = function(v)
        RS.MotoBoxFarm = v
        if v then
            if not RS._loaded.motobox then
                RS._loaded.motobox = safeLoad("https://raw.githubusercontent.com/GaboGC-hub/ride-storm/main/delivery/moto_box_farm.lua")
            end
        end
    end
})

-- ============================
-- Player tab - noclip
-- ============================
local noclipConn
PlayerTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Callback = function(v)
        if v then
            noclipConn = RunService.Heartbeat:Connect(function()
                local char = player.Character
                if not char then return end
                for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end)
        else
            if noclipConn then noclipConn:Disconnect() noclipConn = nil end
        end
    end
})

-- ============================
-- Misc - Anti AFK
-- ============================
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

Rayfield:Notify({ Title = "RideStorm", Content = "Hub cargado correctamente", Duration = 4 })
