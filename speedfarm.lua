--=====================================
-- 🏍️ SPEED FARM REAL (NO TP / NO BUG)
--=====================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local RS = getgenv().RideStorm
if not RS then return end

local conn
local angle = 0

-- CONFIG
local RADIUS = 8        -- studs por tick (≈ velocidad alta)
local ANGLE_STEP = 0.25 -- suavidad del arco
local HEIGHT_LOCK = true

local function getVehicleRoot()
    local char = player.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or not hum.SeatPart then return end

    local seat = hum.SeatPart
    return seat.Parent and seat.Parent.PrimaryPart
end

local function start()
    if conn then return end

    conn = RunService.Heartbeat:Connect(function()
        if not RS.SpeedFarm then return end

        local root = getVehicleRoot()
        if not root then return end

        angle += ANGLE_STEP

        local offset = Vector3.new(
            math.cos(angle) * RADIUS,
            0,
            math.sin(angle) * RADIUS
        )

        local newPos = root.Position + offset

        -- bloquear altura (evita que se entierre o vuele)
        if HEIGHT_LOCK then
            newPos = Vector3.new(newPos.X, root.Position.Y, newPos.Z)
        end

        root.CFrame = CFrame.new(newPos, newPos + offset)
    end)
end

local function stop()
    if conn then
        conn:Disconnect()
        conn = nil
    end
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
