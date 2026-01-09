--=====================================
-- 🏍️ SPEED FARM SUAVE (ANTI-CHOQUES)
--=====================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local SPEED = 140            -- studs/s ≈ 128 km/h
local RADIUS = 120           -- radio del círculo
local ANGLE_SPEED = 1.2      -- velocidad angular (suavidad)

local vel, gyro
local angle = 0
local centerPos

local function getVehicle()
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and hum.SeatPart then
        return hum.SeatPart.Parent
    end
end

local function enableVehicleNoCollide(vehicle)
    for _, v in ipairs(vehicle:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CanCollide = false
        end
    end
end

local function start()
    local veh = getVehicle()
    if not veh then return end

    local root = veh.PrimaryPart or veh:FindFirstChildWhichIsA("BasePart")
    if not root then return end

    centerPos = root.Position
    enableVehicleNoCollide(veh)

    vel = Instance.new("BodyVelocity")
    vel.MaxForce = Vector3.new(1e6, 0, 1e6)
    vel.Parent = root

    gyro = Instance.new("BodyGyro")
    gyro.MaxTorque = Vector3.new(0, 1e6, 0)
    gyro.P = 8000
    gyro.Parent = root
end

local function stop()
    if vel then vel:Destroy() vel = nil end
    if gyro then gyro:Destroy() gyro = nil end
end

RunService.Heartbeat:Connect(function(dt)
    if not getgenv().RideStorm.SpeedFarm then
        stop()
        return
    end

    local veh = getVehicle()
    if not veh or not vel or not gyro then return end

    local root = veh.PrimaryPart or veh:FindFirstChildWhichIsA("BasePart")
    if not root then return end

    -- Movimiento circular (SIN CHOQUES)
    angle += ANGLE_SPEED * dt

    local offset = Vector3.new(
        math.cos(angle) * RADIUS,
        0,
        math.sin(angle) * RADIUS
    )

    local targetPos = centerPos + offset
    local dir = (targetPos - root.Position).Unit

    vel.Velocity = dir * SPEED
    gyro.CFrame = CFrame.lookAt(root.Position, root.Position + dir)
end)

task.spawn(function()
    while task.wait(0.4) do
        if getgenv().RideStorm.SpeedFarm and not vel then
            start()
        end
    end
end)
