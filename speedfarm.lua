-- speedfarm.lua (ESTABLE REAL)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local conn

local function getSeat()
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and hum.SeatPart and hum.SeatPart:IsA("VehicleSeat") then
        return hum.SeatPart
    end
end

conn = RunService.Heartbeat:Connect(function()
    if not getgenv().RideStorm.SpeedFarm then
        conn:Disconnect()
        return
    end

    local seat = getSeat()
    if not seat then return end

    -- SOLO velocidad, NO fuerza vertical, NO giros
    local dir = seat.CFrame.LookVector
    seat.AssemblyLinearVelocity = Vector3.new(
        dir.X * getgenv().RideStorm.SpeedStuds,
        0, -- 🔥 CLAVE: no toca Y
        dir.Z * getgenv().RideStorm.SpeedStuds
    )
end)
