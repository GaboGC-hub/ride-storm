--=====================================
-- 🏍️ SPEED FARM (ESTABLE / AIRE)
--=====================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local SPEED = 120
local DIST = 200
local dir = 1
local velObj
local gyro
local startPos

local function getVehicle()
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and hum.SeatPart then
        return hum.SeatPart.Parent
    end
end

local function prepareVehicle(veh)
    for _, p in ipairs(veh:GetDescendants()) do
        if p:IsA("BasePart") then
            p.CustomPhysicalProperties = PhysicalProperties.new(0.01,0,0,0,0)
        end
    end
end

local function start()
    local veh = getVehicle()
    if not veh then return end

    local root = veh.PrimaryPart or veh:FindFirstChildWhichIsA("BasePart")
    if not root then return end

    prepareVehicle(veh)
    startPos = root.Position

    velObj = Instance.new("BodyVelocity")
    velObj.MaxForce = Vector3.new(1e8,1e8,1e8)
    velObj.Velocity = root.CFrame.LookVector * SPEED
    velObj.P = 2e4
    velObj.Parent = root

    gyro = Instance.new("BodyGyro")
    gyro.MaxTorque = Vector3.new(1e7,1e7,1e7)
    gyro.CFrame = root.CFrame
    gyro.P = 1e4
    gyro.Parent = root
end

local function stop()
    if velObj then velObj:Destroy() velObj=nil end
    if gyro then gyro:Destroy() gyro=nil end
end

RunService.Heartbeat:Connect(function()
    if not getgenv().RideStorm.SpeedFarm then
        stop()
        return
    end

    local veh = getVehicle()
    if not veh or not velObj then return end
    local root = veh.PrimaryPart or veh:FindFirstChildWhichIsA("BasePart")
    if not root then return end

    if (root.Position - startPos).Magnitude >= DIST then
        dir *= -1
        startPos = root.Position
        velObj.Velocity = root.CFrame.LookVector * SPEED * dir
    end

    gyro.CFrame = CFrame.lookAt(root.Position, root.Position + velObj.Velocity)
end)

task.wait(0.2)
start()
