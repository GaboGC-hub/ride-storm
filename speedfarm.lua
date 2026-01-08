--=====================================
-- 🏍️ SPEED FARM (ARC TP – 320 STUDS)
--=====================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- CONFIG
local SPEED_STUDS = 320           -- velocidad objetivo
local STEP_TIME = 0.05            -- tiempo entre pasos
local STEP_DIST = SPEED_STUDS * STEP_TIME
local MAX_DIST = 140              -- largo del arco
local direction = 1

local startPos
local running = false

-- =============================
-- VEHÍCULO REAL
-- =============================
local function getVehicle()
    local char = player.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and hum.SeatPart then
        return hum.SeatPart:FindFirstAncestorOfClass("Model")
    end
end

-- =============================
-- TP VEHÍCULO ESTABLE
-- =============================
local function teleportVehicle(cf)
    local vehicle = getVehicle()
    if not vehicle then return end

    if not vehicle.PrimaryPart then
        vehicle.PrimaryPart = vehicle:FindFirstChildWhichIsA("BasePart")
    end
    if not vehicle.PrimaryPart then return end

    -- limpiar fuerzas
    for _, p in ipairs(vehicle:GetDescendants()) do
        if p:IsA("BasePart") then
            p.AssemblyLinearVelocity = Vector3.zero
            p.AssemblyAngularVelocity = Vector3.zero
        end
    end

    vehicle:SetPrimaryPartCFrame(cf)
end

-- =============================
-- LOOP DE ARCOS
-- =============================
local function startArcFarm()
    if running then return end
    running = true

    task.spawn(function()
        while getgenv().RideStorm.SpeedFarm do
            local veh = getVehicle()
            if not veh or not veh.PrimaryPart then
                task.wait(0.2)
                continue
            end

            local root = veh.PrimaryPart

            if not startPos then
                startPos = root.Position
            end

            local moveDir = root.CFrame.LookVector * direction
            local nextPos = root.Position + (moveDir * STEP_DIST)

            teleportVehicle(
                CFrame.new(nextPos, nextPos + moveDir)
            )

            if (root.Position - startPos).Magnitude >= MAX_DIST then
                direction *= -1
                startPos = root.Position
            end

            task.wait(STEP_TIME)
        end

        running = false
        startPos = nil
    end)
end

-- =============================
-- ACTIVADOR
-- =============================
task.spawn(function()
    while true do
        if getgenv().RideStorm and getgenv().RideStorm.SpeedFarm then
            startArcFarm()
        end
        task.wait(0.3)
    end
end)
