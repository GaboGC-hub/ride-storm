-- Speed Farm Aéreo (Ride Storm compatible)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local RS = getgenv().RideStorm
if not RS then return end

local active = false
local bv, bg
local bikeModel, root

-- encontrar modelo de la moto
local function getBike()
    local char = player.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or not hum.SeatPart then return end

    local seat = hum.SeatPart
    local model = seat:FindFirstAncestorOfClass("Model")
    if not model then return end

    local primary = model.PrimaryPart
    if not primary then
        -- buscar una BasePart válida
        for _, v in ipairs(model:GetDescendants()) do
            if v:IsA("BasePart") then
                primary = v
                break
            end
        end
    end

    return model, primary, seat
end

local function start()
    if active then return end
    active = true

    bikeModel, root, seat = getBike()
    if not bikeModel or not root then
        warn("SpeedFarm: moto no encontrada")
        active = false
        return
    end

    -- elevar moto
    root.CFrame = root.CFrame + Vector3.new(0, 20, 0)

    -- sin colisiones
    for _, v in ipairs(bikeModel:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CanCollide = false
        end
    end

    -- BodyVelocity (movimiento)
    bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
    bv.Velocity = Vector3.zero
    bv.Parent = root

    -- BodyGyro (estabilidad)
    bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
    bg.CFrame = root.CFrame
    bg.Parent = root
end

local function stop()
    active = false
    if bv then bv:Destroy() bv = nil end
    if bg then bg:Destroy() bg = nil end
end

-- loop principal
RunService.Heartbeat:Connect(function()
    if not RS.SpeedFarm then return end

    if not active then
        start()
        return
    end

    if not root or not seat then
        stop()
        return
    end

    -- simular conducción
    seat.Throttle = 1
    seat.Steer = 0

    -- mover hacia adelante
    local speed = RS.SpeedKMH or 150
    local dir = root.CFrame.LookVector
    bv.Velocity = dir * speed

    -- mantener orientación estable
    bg.CFrame = CFrame.new(root.Position, root.Position + dir)
end)

-- Exponer control
RS.StartSeatSpeedFarm = function()
    RS.SpeedFarm = true
end

RS.StopSeatSpeedFarm = function()
    RS.SpeedFarm = false
    stop()
end
