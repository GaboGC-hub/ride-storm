-- Speed Farm Aéreo REAL (Ride Storm)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer

local RS = getgenv().RideStorm
if not RS then return end

local active = false
local ap, ao, att0, att1
local seat, hum, hrp
local sitConn

local function start()
    if active then return end

    local char = Player.Character
    if not char then return end

    hum = char:FindFirstChildOfClass("Humanoid")
    hrp = char:FindFirstChild("HumanoidRootPart")
    seat = hum and hum.SeatPart
    if not seat then return end

    active = true

    -- Attachments
    att0 = Instance.new("Attachment", seat)
    att1 = Instance.new("Attachment", workspace.Terrain)

    -- Align Position
    ap = Instance.new("AlignPosition", seat)
    ap.Attachment0 = att0
    ap.Attachment1 = att1
    ap.MaxForce = math.huge
    ap.MaxVelocity = 200
    ap.Responsiveness = 50

    -- Align Orientation
    ao = Instance.new("AlignOrientation", seat)
    ao.Attachment0 = att0
    ao.Attachment1 = att1
    ao.MaxTorque = math.huge
    ao.Responsiveness = 50

    -- Altura inicial
    local basePos = seat.Position + Vector3.new(0, 180, 0)
    att1.WorldPosition = basePos
    att1.WorldCFrame = seat.CFrame

    -- Mantener sentado
    sitConn = RunService.Stepped:Connect(function()
        if not RS.SpeedFarm or not hum or not seat or not hrp then return end
        hrp.CFrame = seat.CFrame
        if hum.SeatPart ~= seat then
            seat:Sit(hum)
        end
    end)

    -- Movimiento oscilante
    task.spawn(function()
        while RS.SpeedFarm do
            local forward = basePos + seat.CFrame.LookVector * 800
            local back = basePos - seat.CFrame.LookVector * 800

            att1.WorldPosition = forward
            repeat task.wait() until (seat.Position - forward).Magnitude < 35 or not RS.SpeedFarm
            if not RS.SpeedFarm then break end
            task.wait(0.4)

            att1.WorldPosition = back
            repeat task.wait() until (seat.Position - back).Magnitude < 35 or not RS.SpeedFarm
            task.wait(0.4)
        end
    end)
end

local function stop()
    active = false
    if sitConn then sitConn:Disconnect() sitConn = nil end
    if ap then ap:Destroy() end
    if ao then ao:Destroy() end
    if att0 then att0:Destroy() end
    if att1 then att1:Destroy() end
end

RunService.Heartbeat:Connect(function()
    if RS.SpeedFarm then
        if not active then start() end
    else
        if active then stop() end
    end
end)
