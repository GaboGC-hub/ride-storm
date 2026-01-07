-- features/misc.lua
local RS = getgenv().RideStorm
if not RS or not RS.Sections then return end

RS.Sections.Misc:CreateButton({
    Name = "Rejoin",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId)
    end
})

RS.Sections.Misc:CreateLabel({
    Name = "Money Earned: $0"
})

task.spawn(function()
    while true do
        task.wait(1)
        RS.Sections.Misc:CreateLabel({
            Name = "Money Earned: $" .. RS.State.MoneyEarned
        })
    end
end)
