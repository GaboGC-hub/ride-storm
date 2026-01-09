-- remote_debugger.lua
-- Advanced remote + seat tracker (read-only; prints; non-invasive)

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

print("Remote debugger: iniciando. Conduce unos segundos o activa autofarm en moto.")

-- Track seat velocities periodically
spawn(function()
    while task.wait(0.5) do
        local char = player.Character
        if not char then continue end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then continue end
        local seat = hum.SeatPart
        if seat then
            local mag = seat.AssemblyLinearVelocity.Magnitude
            print(string.format("[SEAT] %s | pos=%.2f, vel=%.2f", tostring(seat), seat.Position.Y, mag))
        end
    end
end)

-- Namecall hook to capture remotes (FireServer/InvokeServer)
local ok, mt = pcall(function() return getrawmetatable(game) end)
if not ok then
    warn("remote_debugger: no se pudo obtener metatable")
    return
end

local old = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    local s = tostring(self)
    -- heurística: print calls for most likely candidates, but don't spam everything
    if method == "FireServer" or method == "InvokeServer" then
        local info = {
            target = s,
            method = method,
            args = args,
            time = os.date("%Y-%m-%d %H:%M:%S")
        }
        -- print compact
        local args_str = ""
        for i,v in ipairs(args) do
            local t = typeof(v)
            local sarg = tostring(v)
            if #sarg > 200 then sarg = sarg:sub(1,200) .. "..." end
            args_str = args_str .. "["..i..":"..t.."]="..sarg.."; "
        end
        print(string.format("[REMOTE] %s | %s | %s", info.time, info.target, args_str))
    end
    return old(self, ...)
end)

setreadonly(mt, true)
print("Remote debugger activo. Observa consola mientras conduces o ejecutas autofarm.")
