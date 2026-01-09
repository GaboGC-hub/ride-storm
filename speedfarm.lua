--=====================================
-- 🏍️ SPEED FARM (BOX-LOGIC STYLE)
--=====================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local RS = getgenv().RideStorm
if not RS then return end

local conn
local dir = 1
local baseY
local baseCF

-- CONFIG REAL
local STEP = 6        -- studs por tick (≈ 100–115 km/h reales)
local DIST = 35       -- recorrido corto (anti desync)

local function get()
    local char = player.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")

    if not hum or not hrp then return end
    if not hum.SeatPart then return end -- 🔑 clave

    return hum, hrp
end

local startX

local function start()
    if conn then return end

    local hum, hrp = get()
    if not hum then return end

    baseY = hum.SeatPart.Position.Y
    baseCF = hrp.CFrame
    startX = hrp.Position.X

    conn = RunService.Heartbeat:Connect(function()
        if not RS.SpeedFarm then return end

        -- si se baja, parar
        if not hum.SeatPart then
            RS.SpeedFarm = false
            return
        end

        local offset = Vector3.new(STEP * dir, 0, 0)
        local newPos = hrp.Position + offset

        -- 🔒 fijar Y como en cajas
        newPos = Vector3.new(newPos.X, baseY, newPos.Z)

        hrp.CFrame = CFrame.new(newPos, newPos + offset)

        if math.abs(newPos.X - startX) >= DIST then
            dir *= -1
            startX = newPos.X
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
