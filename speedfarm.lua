-- speedfarm_seat.lua
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local enabled = false
local baseCFrame

local function getSeat()
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and hum.SeatPart and hum.SeatPart:IsA("VehicleSeat") then
        return hum.SeatPart
    end
end

local function start()
    local seat = getSeat()
    if not seat then return end

    baseCFrame = seat.CFrame
    enabled = true
end

local function stop()
    enabled = false
end

RunService.Heartbeat:Connect(function()
    if not enabled then return end

    local seat = getSeat()
    if not seat then
        stop()
        return
    end

    -- Engaño: mantener throttle activo
    seat.Throttle = 1
    seat.Steer = 0

    -- Micro ajuste imperceptible (NO mueve la moto)
    seat.CFrame = baseCFrame
end)

-- Exponer
getgenv().RideStorm = getgenv().RideStorm or {}
getgenv().RideStorm.StartSeatSpeedFarm = start
getgenv().RideStorm.StopSeatSpeedFarm = stop
