-- features/delivery.lua
local RS = getgenv().RideStorm
if not RS then return end

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

local Job = workspace:WaitForChild("DeliveryJob")
local PickupBox = Job.BoxPickingJob.PickupBox
local PickupPrompt = PickupBox:WaitForChild("PickupPrompt")

local DeliverPart = Job.BoxPickingJob.Job.Part
local DeliverPrompt = DeliverPart:WaitForChild("ProximityPrompt")

local running = false

local function farmLoop()
    while RS.State.Autofarm do
        -- recoger
        hrp.CFrame = PickupBox.CFrame + Vector3.new(0,3,0)
        task.wait(0.2)
        fireproximityprompt(PickupPrompt)

        -- entregar
        hrp.CFrame = DeliverPart.CFrame + Vector3.new(0,3,0)
        task.wait(0.2)
        fireproximityprompt(DeliverPrompt)

        task.wait(0.1)
    end
end

RS.Sections.Delivery:CreateToggle({
    Name = "Auto Delivery (Fast)",
    CurrentValue = false,
    Callback = function(v)
        RS.State.Autofarm = v
        if v and not running then
            running = true
            task.spawn(function()
                farmLoop()
                running = false
            end)
        end
    end
})
