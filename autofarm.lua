-- autofarm.lua (Auto Delivery robusto)
-- This script expects getgenv().RideStorm defined and RS.BoxFarm toggled.

local RS = getgenv().RideStorm
if not RS then return end

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

-- wait for DeliveryJob nodes (streaming-safe)
local function waitForPath(pathRoot, timeout)
    local elapsed = 0
    while elapsed < (timeout or 10) do
        local ok = workspace:FindFirstChild(pathRoot)
        if ok then return ok end
        task.wait(0.5)
        elapsed = elapsed + 0.5
    end
    return nil
end

local jobRoot = waitForPath("DeliveryJob", 12)
if not jobRoot then
    warn("AutoFarm: DeliveryJob no encontrado")
    return
end

local pickupBox = jobRoot:FindFirstChild("BoxPickingJob") and jobRoot.BoxPickingJob:FindFirstChild("PickupBox")
if not pickupBox then
    warn("AutoFarm: PickupBox no encontrado")
    return
end
local pickupPrompt = pickupBox:FindFirstChild("PickupPrompt") or pickupBox:FindFirstChildWhichIsA("ProximityPrompt", true)
local jobPart = jobRoot.BoxPickingJob:FindFirstChild("Job") and jobRoot.BoxPickingJob.Job:FindFirstChild("Part")
local jobPrompt = jobPart and (jobPart:FindFirstChild("ProximityPrompt") or jobPart:FindFirstChildWhichIsA("ProximityPrompt", true))

if not pickupPrompt or not jobPrompt then
    warn("AutoFarm: prompts no encontrados")
    return
end

-- Estimate money update function hook (optional)
local rewardEstimate = 0 -- set to 0 to rely on real leaderstats instead
if RS.UpdateMoney == nil then
    RS.UpdateMoney = function(amount) end
end

while RS.BoxFarm do
    if not player.Character then break end
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then task.wait(0.5) continue end

    -- go pickup
    pcall(function()
        hrp.CFrame = pickupBox.CFrame + Vector3.new(0, 3, 0)
    end)
    task.wait(0.12)
    pcall(function() fireproximityprompt(pickupPrompt, 1) end)
    task.wait(0.12)

    -- deliver
    pcall(function()
        hrp.CFrame = jobPart.CFrame + Vector3.new(0, 3, 0)
    end)
    task.wait(0.12)
    pcall(function() fireproximityprompt(jobPrompt, 1) end)
    task.wait(0.12)

    -- notify (optional)
    if rewardEstimate > 0 and RS.UpdateMoney then
        RS.UpdateMoney(rewardEstimate)
    end

    task.wait(0.05)
end
