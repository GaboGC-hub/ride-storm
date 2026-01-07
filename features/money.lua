-- features/money.lua
local RS = getgenv().RideStorm
if not RS then return end

local player = game.Players.LocalPlayer

local function hookLeaderstats()
    local stats = player:WaitForChild("leaderstats", 10)
    if not stats then return end

    local money = stats:FindFirstChild("Money") or stats:FindFirstChild("Cash")
    if not money then return end

    RS.State.LastMoney = money.Value

    money:GetPropertyChangedSignal("Value"):Connect(function()
        local diff = money.Value - RS.State.LastMoney
        if diff > 0 then
            RS.State:AddMoney(diff)
        end
        RS.State.LastMoney = money.Value
    end)
end

task.spawn(hookLeaderstats)
