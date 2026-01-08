-- =============================
-- ⚡ SPEED FARM AFK (FREEZE)
-- =============================

local RunService = game:GetService("RunService")
local player = game.Players.LocalPlayer
local RS = getgenv().RideStorm

local SPEED = 300 -- studs/s reales
local savedCFrame = nil

RunService.Heartbeat:Connect(function()
    if not RS or not RS.SpeedFarm then
        savedCFrame = nil
        return
    end

    local char = player.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if not savedCFrame then
        savedCFrame = hrp.CFrame
    end

    hrp.CFrame = savedCFrame
    hrp.AssemblyLinearVelocity = Vector3.new(SPEED, 0, 0)
    hrp.AssemblyAngularVelocity = Vector3.zero
end)
