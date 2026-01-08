-- =====================================
-- 🏍️📦 MOTO + BOX DELIVERY FARM
-- =====================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local RS = getgenv().RideStorm

if not RS then
    warn("RideStorm state not found")
    return
end

-- CONFIG
local TP_DISTANCE = 80        -- studs por salto (≈ 72 km/h)
local TP_INTERVAL = 0.25      -- segundos entre TPs
local HEIGHT_OFFSET = 6       -- evita colisiones

-- Utils
local function getVehicle()
    local char = player.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and hum.SeatPart then
        return hum.SeatPart.Parent
    end
end

local lastTp = 0

RunService.Heartbeat:Connect(function()
    if not RS.MotoBoxFarm then return end

    local vehicle = getVehicle()
    if not vehicle then return end

    local root = vehicle.PrimaryPart or vehicle:FindFirstChildWhichIsA("BasePart")
    if not root then return end

    -- Asegurar PrimaryPart
    if not vehicle.PrimaryPart then
        vehicle.PrimaryPart = root
    end

    -- Control de tiempo
    if tick() - lastTp < TP_INTERVAL then return end
    lastTp = tick()

    -- Dirección
    local cf = root.CFrame
    local forward = cf.LookVector

    -- Nuevo CFrame
    local newCF =
        cf +
        (forward * TP_DISTANCE) +
        Vector3.new(0, HEIGHT_OFFSET, 0)

    -- 🔑 TELEPORT DEL VEHÍCULO (NO DEL PLAYER)
    vehicle:SetPrimaryPartCFrame(newCF)

    -- Estabilizar
    root.AssemblyAngularVelocity = Vector3.zero
    root.AssemblyLinearVelocity = forward * (TP_DISTANCE / TP_INTERVAL)
end)
