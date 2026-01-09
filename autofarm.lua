-- Auto Delivery Farm (única fuente de verdad)

local RS = getgenv().RideStorm
if not RS then return end

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local function getHRP()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end

task.spawn(function()
    while true do
        if RS.Farming then
            local hrp = getHRP()

            local pickupBox = workspace.DeliveryJob.BoxPickingJob.PickupBox
            local pickupPrompt = pickupBox:WaitForChild("PickupPrompt")

            local jobPart = workspace.DeliveryJob.BoxPickingJob.Job.Part
            local jobPrompt = jobPart:WaitForChild("ProximityPrompt")

            while RS.Farming do
                hrp.CFrame = pickupBox.CFrame + Vector3.new(0,5,0)
                task.wait(0.15)
                fireproximityprompt(pickupPrompt, 1)

                hrp.CFrame = jobPart.CFrame + Vector3.new(0,5,0)
                task.wait(0.15)
                fireproximityprompt(jobPrompt, 1)

                task.wait(0.1)
            end
        end
        task.wait(0.5)
    end
end)
