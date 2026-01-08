local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local SPEED_STUDS = 130 -- ≈ 115–120 km/h reales
local DIST = 200
local dir = 1
local startPos
local lv

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

    startPos = root.Position

    lv = Instance.new("LinearVelocity")
    lv.Attachment0 = root:FindFirstChildWhichIsA("Attachment") or Instance.new("Attachment", root)
    lv.MaxForce = math.huge
    lv.VectorVelocity = root.CFrame.LookVector * SPEED_STUDS
    lv.RelativeTo = Enum.ActuatorRelativeTo.World
    lv.Parent = root
end

local function stop()
    if lv then lv:Destroy() lv = nil end
end

RunService.Heartbeat:Connect(function()
    if not getgenv().RideStorm.SpeedFarm then
        stop()
        return
    end

    local veh = getVehicle()
    if not veh or not lv then return end
    local root = veh.PrimaryPart or veh:FindFirstChildWhichIsA("BasePart")
    if not root then return end

    if (root.Position - startPos).Magnitude >= DIST then
        dir *= -1
        startPos = root.Position
        lv.VectorVelocity = root.CFrame.LookVector * SPEED_STUDS * dir
    end
end)

task.wait(0.2)
start()
