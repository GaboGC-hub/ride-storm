--=====================================
-- 🏍️ SPEED FARM (SAFE – NO VEHICLE MOVE)
--=====================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local RS = getgenv().RideStorm
if not RS then return end

local conn
local dir = 1

-- CONFIG REAL
local STEP = 4.5        -- studs por tick (≈ 85–95 km/h reales)
local DIST = 40         -- recorrido corto (anti desync)

local function getHumanoid()
    local char = player.Character
    if not char then return end
    return char:FindFirstChildOfClass("Humanoid"), char:FindFirstChild("HumanoidRootPart")
end

local startPos

local function start()
    if conn then return end

    local hum, hrp = getHumanoid()
    if not hum or not hrp then return end
    if not hum.SeatPart then return end -- 🔑 CLAVE

    startPos = hrp.Position

    conn = RunService.Heartbeat:Connect(function()
        if not RS.SpeedFarm then return end

        -- si se baja, parar
        if not hum.SeatPart then
            RS.SpeedFarm = false
            return
        end

        local offset = Vector3.new(STEP * dir, 0, 0)
        hrp.CFrame = hrp.CFrame + offset

        if (hrp.Position - startPos).Magnitude >= DIST then
            dir *= -1
            startPos = hrp.Position
        end
    end)
end

local function stop()
    if conn then
        conn:Disconnect()
        conn = nil
    end
end

task.spawn(function()
    while task.wait(0.2) do
        if RS.SpeedFarm then
            start()
        else
            stop()
        end
    end
end)
