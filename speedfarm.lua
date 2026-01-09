--=====================================
-- 🏍️ SPEED FARM OPTIMIZADO
--=====================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local SPEED = 140 -- studs/s ≈ 128 km/h (ajustable)
local RANGE = 120
local direction = 1

local vel
local originPos

local function getVehicle()
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and hum.SeatPart then
        return hum.SeatPart.Parent
    end
end

local function start()
    local veh = getVehicle()
    if not veh then return end

    local root = veh.PrimaryPart or veh:FindFirstChildWhichIsA("BasePart")
    if not root then return end

    originPos = root.Position

    vel = Instance.new("BodyVelocity")
    vel.MaxForce = Vector3.new(1e6, 0, 1e6)
    vel.Velocity = root.CFrame.LookVector * SPEED
    vel.Parent = root
end

local function stop()
    if vel then vel:Destroy() vel = nil end
end

RunService.Heartbeat:Connect(function()
    if not getgenv().RideStorm.SpeedFarm then
        stop()
        return
    end

    local veh = getVehicle()
    if not veh or not vel then return end

    local root = veh.PrimaryPart or veh:FindFirstChildWhichIsA("BasePart")
    if not root then return end

    if (root.Position - originPos).Magnitude > RANGE then
        direction *= -1
        originPos = root.Position
        vel.Velocity = root.CFrame.LookVector * SPEED * direction
    end
end)

task.spawn(function()
    while task.wait(0.3) do
        if getgenv().RideStorm.SpeedFarm and not vel then
            start()
        end
    end
end)
