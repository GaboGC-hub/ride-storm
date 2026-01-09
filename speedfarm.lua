-- speedfarm.lua (RideStorm) - LinearVelocity con fallback

-- Evitar doble carga
if getgenv()._RideStorm_SpeedFarm_Loaded then return end
getgenv()._RideStorm_SpeedFarm_Loaded = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local RS = getgenv().RideStorm or {}

-- Config (ajusta TARGET_STUDS si quieres)
-- En tu juego la escala era ~0.9 km/h per stud, tú dijiste 90 studs ≈ 82 km/h.
-- TARGET_STUDS está en studs/seg. Ajusta si quieres.
local TARGET_STUDS = 200   -- objetivo por defecto (studs/s). Súbelo si quieres más $/s.
local ACCEL_RATE = 30      -- cuanto aumenta por segundo (studs/s^2)
local MAX_TRAVEL = 180     -- distancia antes de invertir (studs)

-- Estado
local running = false
local lv -- LinearVelocity
local gyro -- BodyGyro
local currentSpeed = 0
local startPos
local dir = 1
local attachedAttachment

-- Helpers
local function getVehicleRoot()
    local char = player.Character
    if not char then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and hum.SeatPart and hum.SeatPart:IsA("VehicleSeat") then
        local model = hum.SeatPart:FindFirstAncestorOfClass("Model") or hum.SeatPart.Parent
        local root = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
        return model, root
    end
    return nil, nil
end

local function safeCreateAttachment(root)
    local att = root:FindFirstChild("RideStorm_Attachment")
    if att and att:IsA("Attachment") then return att end
    local ok, attc = pcall(function()
        local a = Instance.new("Attachment")
        a.Name = "RideStorm_Attachment"
        a.Parent = root
        return a
    end)
    return ok and attc or nil
end

local function startEngine()
    if running then return end
    running = true
    currentSpeed = 0
    dir = 1
    startPos = nil

    spawn(function()
        while running do
            if not RS.SpeedFarm then
                running = false
                break
            end

            local model, root = getVehicleRoot()
            if not model or not root then
                task.wait(0.25)
                currentSpeed = 0
                -- wait until user mounts
                continue
            end

            if not startPos then startPos = root.Position end

            -- ensure attachment
            attachedAttachment = safeCreateAttachment(root)

            -- create LinearVelocity + BodyGyro if missing
            if not lv then
                local ok, _ = pcall(function()
                    lv = Instance.new("LinearVelocity")
                    lv.Name = "RideStorm_LV"
                    lv.Attachment0 = attachedAttachment
                    lv.RelativeTo = Enum.ActuatorRelativeTo.World
                    lv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                    lv.Parent = root
                end)
                if not ok then
                    -- fallback will be created later in tick
                    lv = nil
                end
            end

            if not gyro then
                local okg, _ = pcall(function()
                    gyro = Instance.new("BodyGyro")
                    gyro.Name = "RideStorm_GYRO"
                    gyro.MaxTorque = Vector3.new(1e8, 1e8, 1e8)
                    gyro.P = 1e4
                    gyro.Parent = root
                end)
                if not okg then gyro = nil end
            end

            -- accelerate smoothly
            local dt = math.min(0.1, task.wait(0.05))
            currentSpeed = math.min(TARGET_STUDS, currentSpeed + ACCEL_RATE * dt)

            local targetVel = (root.CFrame.LookVector * currentSpeed * dir)

            if lv then
                pcall(function() lv.VectorVelocity = targetVel end)
            else
                -- fallback to BodyVelocity
                if not root:FindFirstChild("RideStorm_BV") then
                    local okbv = pcall(function()
                        local bv = Instance.new("BodyVelocity")
                        bv.Name = "RideStorm_BV"
                        bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                        bv.P = 1e4
                        bv.Parent = root
                    end)
                end
                local bv = root:FindFirstChild("RideStorm_BV")
                if bv then
                    pcall(function() bv.Velocity = targetVel end)
                end
            end

            if gyro then
                pcall(function()
                    gyro.CFrame = CFrame.lookAt(root.Position, root.Position + (targetVel))
                end)
            end

            -- invert direction if traveled enough
            if (root.Position - startPos).Magnitude >= MAX_TRAVEL then
                dir = dir * -1
                startPos = root.Position
                -- small break to avoid instant flip backlash
                currentSpeed = math.max( math.floor(currentSpeed * 0.6), 0)
            end
        end

        -- cleanup
        pcall(function()
            if lv then lv:Destroy() lv = nil end
            if gyro then gyro:Destroy() gyro = nil end
            -- remove fallback BV if any
            local model, r = getVehicleRoot()
            if r then
                local bv = r:FindFirstChild("RideStorm_BV")
                if bv then bv:Destroy() end
            end
        end)
    end)
end

-- Shutdown when RS.SpeedFarm false
spawn(function()
    while true do
        task.wait(0.4)
        if getgenv().RideStorm == nil then break end
        if not getgenv().RideStorm.SpeedFarm then
            running = false
        else
            if not running then startEngine() end
        end
    end
end)
