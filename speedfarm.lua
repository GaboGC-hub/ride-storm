--=====================================
-- 🏍️ SPEED FARM ESTABLE (NO CAE / NO CHOCA)
--=====================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

-- ===== CONFIG =====
local SPEED = 180           -- studs/s (~128 km/h real)
local RADIUS = 120
local ANGLE_SPEED = 1.2
local HEIGHT_OFFSET = 4.5  -- altura sobre el suelo (CRÍTICO)
local RAY_DISTANCE = 40

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

    angle += ANGLE_SPEED * dt

    -- movimiento circular SOLO XZ
    local moveDir = Vector3.new(
        math.cos(angle),
        0,
        math.sin(angle)
    ).Unit

    -- velocidad PLANA
    vel.Velocity = moveDir * SPEED

    -- raycast al suelo
    local rayResult = Workspace:Raycast(
        root.Position,
        Vector3.new(0, -RAY_DISTANCE, 0),
        rayParams
    )

    if rayResult then
        -- 🔒 ALTURA BLOQUEADA (NO VELOCIDAD)
        root.CFrame = CFrame.new(
            root.Position.X,
            rayResult.Position.Y + HEIGHT_OFFSET,
            root.Position.Z
        )
    end

    -- orientación suave
    gyro.CFrame = CFrame.lookAt(
        root.Position,
        root.Position + moveDir
    )
end)

task.spawn(function()
    while task.wait(0.5) do
        if getgenv().RideStorm.SpeedFarm and not vel then
            start()
        end
    end
end)
