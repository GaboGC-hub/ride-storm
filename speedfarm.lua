--=====================================
-- 🏍️ SPEED FARM REAL (VELOCIDAD CONTINUA)
--=====================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local SPEED = 90 -- studs/s ≈ 160 km/h (sube si quieres)
local MAX_DIST = 150
local dir = 1

local velObj
local startPos

local function getVehicle()
    local char = player.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and hum.SeatPart then
        return hum.SeatPart.Parent
    end
end

local function startSpeedFarm()
    local veh = getVehicle()
    if not veh then return end

    local root = veh.PrimaryPart or veh:FindFirstChildWhichIsA("BasePart")
    if not root then return end

    startPos = root.Position

    velObj = Instance.new("BodyVelocity")
    velObj.MaxForce = Vector3.new(1e6, 0, 1e6)
    velObj.Velocity = root.CFrame.LookVector * SPEED
    velObj.Parent = root

    -- suspender en el aire (no suelo)
    root.Anchored = false
end

local function stopSpeedFarm()
    if velObj then velObj:Destroy() velObj = nil end
end

RunService.Heartbeat:Connect(function()
    if not getgenv().RideStorm.SpeedFarm then
        stopSpeedFarm()
        return
    end

    local veh = getVehicle()
    if not veh then return end

    local root = veh.PrimaryPart or veh:FindFirstChildWhichIsA("BasePart")
    if not root or not velObj then return end

    if (root.Position - startPos).Magnitude >= MAX_DIST then
        dir *= -1
        startPos = root.Position
        velObj.Velocity = root.CFrame.LookVector * SPEED * dir
    end
end)

-- auto start
task.spawn(function()
    while true do
        if getgenv().RideStorm.SpeedFarm and not velObj then
            startSpeedFarm()
        end
        task.wait(0.3)
    end
end)
