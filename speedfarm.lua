local RunService = game:GetService("RunService")
local player = game.Players.LocalPlayer

local SPEED = 40 -- studs/s ≈ 120–130 km/h
local DIST = 200
local dir = 1
local vel, startPos

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

    root.AssemblyLinearVelocity = Vector3.zero

    vel = Instance.new("BodyVelocity")
    vel.MaxForce = Vector3.new(1e7,1e7,1e7)
    vel.Velocity = root.CFrame.LookVector * SPEED
    vel.Parent = root

    startPos = root.Position
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

    if (root.Position - startPos).Magnitude > DIST then
        dir *= -1
        startPos = root.Position
        vel.Velocity = root.CFrame.LookVector * SPEED * dir
    end
end)

task.delay(0.3, start)
