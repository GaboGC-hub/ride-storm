local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local TARGET_SPEED = 140 -- studs/s ≈ 100–120 km/h reales
local FORCE = 6000

local lv

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

    if lv then lv:Destroy() end

    lv = Instance.new("LinearVelocity")
    lv.Attachment0 = root:FindFirstChildOfClass("Attachment") 
        or Instance.new("Attachment", root)

    lv.MaxForce = FORCE
    lv.VectorVelocity = root.CFrame.LookVector * TARGET_SPEED
    lv.RelativeTo = Enum.ActuatorRelativeTo.World
    lv.Parent = root
end

local function stopSpeedFarm()
    if lv then
        lv:Destroy()
        lv = nil
    end
end

RunService.Heartbeat:Connect(function()
    if not getgenv().RideStorm.SpeedFarm then
        stopSpeedFarm()
        return
    end

    local veh = getVehicle()
    if not veh then return end
    local root = veh.PrimaryPart or veh:FindFirstChildWhichIsA("BasePart")
    if not root or not lv then return end

    -- mantener dirección sin volar
    lv.VectorVelocity = root.CFrame.LookVector * TARGET_SPEED
end)

task.delay(0.3, startSpeedFarm)
