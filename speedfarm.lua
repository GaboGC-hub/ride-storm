-- Speed Farm REAL (NO ROMPE MOTO)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local function getSeat()
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and hum.SeatPart and hum.SeatPart:IsA("VehicleSeat") then
        return hum.SeatPart
    end
end

local conn
conn = RunService.Heartbeat:Connect(function()
    if not getgenv().RideStorm.SpeedFarm then
        if conn then conn:Disconnect() end
        return
    end

    local seat = getSeat()
    if not seat then return end

    local vel = seat.CFrame.LookVector * getgenv().RideStorm.SpeedStuds
    seat.AssemblyLinearVelocity =
        Vector3.new(vel.X, seat.AssemblyLinearVelocity.Y, vel.Z)
end)
