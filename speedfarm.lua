-- =====================================
-- 🏍️ SPEED FARM (300 STUDS/S REAL)
-- =====================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local RS = getgenv().RideStorm
if not RS then return end

-- CONFIG
local SPEED = 300 -- studs/s (exacto, como pediste)

local seat
local root

local function getVehicle()
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and hum.SeatPart then
        seat = hum.SeatPart
        root = seat.Parent.PrimaryPart or seat
        return true
    end
end

RunService.Heartbeat:Connect(function()
    if not RS.SpeedFarm then return end
    if not getVehicle() then return end
    if not root then return end

    -- Dirección fija hacia adelante
    local dir = root.CFrame.LookVector

    -- Velocidad SIN eje Y (no vuela)
    root.AssemblyLinearVelocity = Vector3.new(
        dir.X * SPEED,
        root.AssemblyLinearVelocity.Y,
        dir.Z * SPEED
    )

    -- Bloquea rotación extraña
    root.AssemblyAngularVelocity = Vector3.zero
end)
