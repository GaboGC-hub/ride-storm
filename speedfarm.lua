local RunService = game:GetService("RunService")
local player = game.Players.LocalPlayer
local RS = getgenv().RS

local conn
local studsPerSec = 0

local function kmhToStuds(kmh)
    return kmh * 0.277778 * 3.57 -- conversión estable
end

function RS.StartSpeedFarm()
    if conn then return end

    conn = RunService.Heartbeat:Connect(function(dt)
        local char = player.Character
        if not char then return end

        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hum or not hrp then return end

        -- 🔥 SE LEE EN TIEMPO REAL
        studsPerSec = kmhToStuds(RS.SpeedKMH or 120)

        local move = hrp.CFrame.LookVector * studsPerSec * dt
        hrp.CFrame += move + Vector3.new(0, RS.FlyHeight or 200, 0)
    end)
end

function RS.StopSpeedFarm()
    if conn then
        conn:Disconnect()
        conn = nil
    end
end
