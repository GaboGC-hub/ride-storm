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
    if not RS.SpeedFarm then return end

    local char = player.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or not hum.SeatPart then return end

    local seat = hum.SeatPart
    if not seat:IsA("VehicleSeat") then return end

    seat.Throttle = 1
    seat.Steer = 0
    seat:SetAttribute("Speed", RS.SpeedKMH)
end)

-- Exponer
getgenv().RideStorm = getgenv().RideStorm or {}
getgenv().RideStorm.StartSeatSpeedFarm = start
getgenv().RideStorm.StopSeatSpeedFarm = stop
