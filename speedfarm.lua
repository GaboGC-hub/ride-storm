--=====================================
-- 🏍️ SPEED FARM ESTABLE (NO CAE / NO CHOCA)
--=====================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

-- ===== CONFIG =====
local SPEED = 140            -- studs/s (~128 km/h real)
local RADIUS = 110
local ANGLE_SPEED = 1.1
local HEIGHT_OFFSET = 3.5    -- altura sobre el suelo (CRÍTICO)
local RAY_DISTANCE = 20

-- ==================
local vel, gyro
local angle = 0
local centerPos

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Blacklist

local function getVehicle()
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and hum.SeatPart then
        return hum.SeatPart.Parent
    end
end

local function noCollideVehicle(vehicle)
    for _, p in ipairs(vehicle:GetDescendants()) do
        if p:IsA("BasePart") then
            p.CanCollide = false
        end
    end
end

local function start()
    local veh = getVehicle()
    if not veh then return end

    local root = veh.PrimaryPart or veh:FindFirstChildWhichIsA("BasePart")
    if not root then return end

    centerPos = root.Position
    rayParams.FilterDescendantsInstances = {veh, player.Character}

    noCollideVehicle(veh)

    vel = Instance.new("BodyVelocity")
    vel.MaxForce = Vector3.new(1e6, 1e6, 1e6)
    vel.Parent = root

    gyro = Instance.new("BodyGyro")
    gyro.MaxTorque = Vector3.new(0, 1e6, 0)
    gyro.P = 9000
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

    -- 🔄 movimiento circular suave
    angle += ANGLE_SPEED * dt
    local offset = Vector3.new(
        math.cos(angle) * RADIUS,
        0,
        math.sin(angle) * RADIUS
    )

    -- 📡 raycast al suelo
    local rayResult = Workspace:Raycast(
        root.Position,
        Vector3.new(0, -RAY_DISTANCE, 0),
        rayParams
    )

    local y = root.Position.Y
    if rayResult then
        y = rayResult.Position.Y + HEIGHT_OFFSET
    end

    local targetPos = Vector3.new(
        centerPos.X + offset.X,
        y,
        centerPos.Z + offset.Z
    )

    local dir = (targetPos - root.Position).Unit

    vel.Velocity = dir * SPEED
    gyro.CFrame = CFrame.lookAt(root.Position, root.Position + dir)
end)

task.spawn(function()
    while task.wait(0.5) do
        if getgenv().RideStorm.SpeedFarm and not vel then
            start()
        end
    end
end)
