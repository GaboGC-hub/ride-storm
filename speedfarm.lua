-- =============================
-- ⚡ SPEED FARM REAL (VEHÍCULO)
-- =============================

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local RS = getgenv().RideStorm

local SPEED = 300 -- studs/s reales
local lockCF = nil
local velObj

local function getVehicle()
    local char = player.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and hum.SeatPart then
        return hum.SeatPart.Parent
    end
end

RunService.Heartbeat:Connect(function()
    if not RS or not RS.SpeedFarm then
        if velObj then velObj:Destroy() velObj = nil end
        lockCF = nil
        return
    end

    local vehicle = getVehicle()
    if not vehicle then return end

    local root = vehicle.PrimaryPart or vehicle:FindFirstChildWhichIsA("BasePart")
    if not root then return end

    if not lockCF then
        lockCF = root.CFrame

        velObj = Instance.new("BodyVelocity")
        velObj.MaxForce = Vector3.new(1e9, 0, 1e9)
        velObj.Velocity = root.CFrame.LookVector * SPEED
        velObj.Parent = root
    end

    -- 🔒 bloquea posición (no se cae / no vuela)
    root.CFrame = lockCF
    root.AssemblyAngularVelocity = Vector3.zero
end)
