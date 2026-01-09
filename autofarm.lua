-- Autofarm original adaptado (estable)

local RS = getgenv().RideStorm
if not RS then return end

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local hrp
local pickupBox
local pickupPrompt
local jobPart
local jobPrompt

local function setup()
    local char = player.Character or player.CharacterAdded:Wait()
    hrp = char:WaitForChild("HumanoidRootPart")

    pickupBox = workspace.DeliveryJob.BoxPickingJob.PickupBox
    pickupPrompt = pickupBox:WaitForChild("PickupPrompt")

    jobPart = workspace.DeliveryJob.BoxPickingJob.Job.Part
    jobPrompt = jobPart:WaitForChild("ProximityPrompt")
end

-- rehacer referencias si mueres
player.CharacterAdded:Connect(function()
    task.wait(0.5)
    if RS.Farming then
        setup()
    end
end)

task.spawn(function()
    while true do
        if RS.Farming then
            pcall(setup)

            while RS.Farming do
                hrp.CFrame = pickupBox.CFrame + Vector3.new(0,3,0)
                task.wait(0.15)
                fireproximityprompt(pickupPrompt, 1)

                hrp.CFrame = jobPart.CFrame + Vector3.new(0,3,0)
                task.wait(0.15)
                fireproximityprompt(jobPrompt, 1)

                task.wait(math.random(8,15)/100)
            end
        end
        task.wait(0.3)
    end
end)

print("✅ Autofarm adaptado cargado")
