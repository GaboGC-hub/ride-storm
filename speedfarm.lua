-- speedfarm.lua (integrable, seguro)
if getgenv()._RideStormSpeedLoaded then return end
getgenv()._RideStormSpeedLoaded = true

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local RS = getgenv().RideStorm or {}

-- Convert km/h to studs/s (use your measured factor)
local function kmhToStuds(kmh) return kmh * 1.11 end

local conn

local function getSeat()
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    return hum.SeatPart
end

local function start()
    if conn then return end
    conn = RunService.Heartbeat:Connect(function()
        if not RS.SpeedFarm then return end
        local seat = getSeat()
        if not seat then return end

        -- spoof only horizontal components; keep Y as is to avoid sudden falls
        local desired = seat.CFrame.LookVector * kmhToStuds(RS.SpeedKMH)
        local currentY = seat.AssemblyLinearVelocity.Y
        seat.AssemblyLinearVelocity = Vector3.new(desired.X, currentY, desired.Z)
    end)
end

local function stop()
    if conn then conn:Disconnect() conn = nil end
end

-- monitor RS.SpeedFarm
spawn(function()
    while true do
        task.wait(0.25)
        if getgenv().RideStorm == nil then break end
        if getgenv().RideStorm.SpeedFarm then
            start()
        else
            stop()
        end
    end
end)
