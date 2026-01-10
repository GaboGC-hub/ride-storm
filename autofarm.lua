-- Auto Delivery Farm

local RS = getgenv().RideStorm
if not RS or not RS.Farming then return end

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

local pickupBox = workspace.DeliveryJob.BoxPickingJob.PickupBox
local pickupPrompt = pickupBox:WaitForChild("PickupPrompt")

local jobPart = workspace.DeliveryJob.BoxPickingJob.Job.Part
local jobPrompt = jobPart:WaitForChild("ProximityPrompt")

while RS.Farming do
    -- ir a recoger
    hrp.CFrame = pickupBox.CFrame + Vector3.new(0,3,0)
    hrp.CFrame = pickupBox.CFrame + Vector3.new(0,5,0)
    task.wait(0.15)
    fireproximityprompt(pickupPrompt, 1)

    -- entregar
    hrp.CFrame = jobPart.CFrame + Vector3.new(0,3,0)
    task.wait(3)
    hrp.CFrame = jobPart.CFrame + Vector3.new(0,5,0)
    task.wait(0.15)
    fireproximityprompt(jobPrompt, 1)

    -- dinero estimado
    if RS.UpdateMoney then
        RS.UpdateMoney(100) -- ajusta al reward real
    end

    task.wait(math.random(8,15)/100)
end
