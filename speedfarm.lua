-- Speed Farm Aéreo ESTABLE (Ride Storm)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local RS = getgenv().RideStorm
if not RS then return end

local active = false
local bikeModel, root, seat
local baseCF

-- obtener moto
local function getBike()
    local char = player.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or not hum.SeatPart then return end

    seat = hum.SeatPart
    bikeModel = seat:FindFirstAncestorOfClass("Model")
    if not bikeModel then return end

    root = bikeModel.PrimaryPart
    if not root then
        for _, v in ipairs(bikeModel:GetDescendants()) do
            if v:IsA("BasePart") then
                root = v
                break
            end
        end
    end

    return bikeModel and root and seat
end

local function start()
    if active then return end
    if not getBike() then return end
    active = true

    -- elevar moto
    baseCF = root.CFrame + Vector3.new(0, 50, 0)
    root.CFrame = baseCF

    -- anclar TODO
    for _, v in ipairs(bikeModel:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Anchored = true
            v.CanCollide = false
        end
    end
end

local function stop()
    active = false
    if not bikeModel then return end

    for _, v in ipairs(bikeModel:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Anchored = false
            v.CanCollide = true
        end
    end
end

RunService.Heartbeat:Connect(function()
    if not RS.SpeedFarm then
        if active then stop() end
        return
    end

    if not active then
        start()
        return
    end

    if not root or not seat then
        stop()
        return
    end

    -- simular manejo (sin física)
    seat.Throttle = 1
    seat.Steer = 0

    local speed = (RS.SpeedKMH or 150) / 20
    baseCF = baseCF * CFrame.new(0, 0, -speed)
    root.CFrame = baseCF
end)

RS.StartSeatSpeedFarm = function()
    RS.SpeedFarm = true
end

RS.StopSeatSpeedFarm = function()
    RS.SpeedFarm = false
    stop()
end
