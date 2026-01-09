--=====================================
-- 🏍️ SPEED FARM ESTABLE (ANTI BUG)
--=====================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local RS = getgenv().RideStorm
if not RS then return end

local conn
local angle = 0
local cachedParts = {}

-- CONFIG REALISTA
local STEP = 5        -- studs por tick (≈ 90–110 km/h reales)
local ANGLE_STEP = 0.18
local HEIGHT_OFFSET = 0

local function getVehicle()
    local char = player.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or not hum.SeatPart then return end

    local veh = hum.SeatPart.Parent
    local root = veh.PrimaryPart or veh:FindFirstChildWhichIsA("BasePart")
    if not root then return end

    return veh, root
end

-- 🔒 FREEZE FÍSICA (clave)
local function lockVehicle(veh)
    cachedParts = {}
    for _, v in ipairs(veh:GetDescendants()) do
        if v:IsA("BasePart") then
            cachedParts[v] = v.CanCollide
            v.CanCollide = false
            v.AssemblyLinearVelocity = Vector3.zero
            v.AssemblyAngularVelocity = Vector3.zero
        end
        if v:IsA("HingeConstraint") or v:IsA("SpringConstraint") then
            v.Enabled = false
        end
    end
end

local function unlockVehicle()
    for part, collide in pairs(cachedParts) do
        if part and part.Parent then
            part.CanCollide = collide
        end
    end
    cachedParts = {}
end

local function start()
    if conn then return end

    local veh, root = getVehicle()
    if not veh then return end

    lockVehicle(veh)
    local baseY = root.Position.Y

    conn = RunService.Heartbeat:Connect(function()
        if not RS.SpeedFarm then return end

        angle += ANGLE_STEP

        local offset = Vector3.new(
            math.cos(angle) * STEP,
            0,
            math.sin(angle) * STEP
        )

        local pos = root.Position + offset
        pos = Vector3.new(pos.X, baseY + HEIGHT_OFFSET, pos.Z)

        root.CFrame = CFrame.new(pos, pos + offset)
    end)
end

local function stop()
    if conn then
        conn:Disconnect()
        conn = nil
    end
    unlockVehicle()
end

-- LOOP
task.spawn(function()
    while task.wait(0.2) do
        if RS.SpeedFarm then
            start()
        else
            stop()
        end
    end
end)
