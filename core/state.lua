-- core/state.lua
getgenv().RideStorm = getgenv().RideStorm or {}
local RS = getgenv().RideStorm

RS.State = RS.State or {
    Autofarm = false,
    MoneyEarned = 0
}
