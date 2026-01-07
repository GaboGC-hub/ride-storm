-- features/misc.lua
local RS = getgenv().RideStorm
if not RS or not RS.Sections then return end

RS.Sections.Misc:CreateButton({
    Name = "Rejoin",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId)
    end
})
