-- Speed Farm Fly PRO (Ride Storm)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer

local RS = getgenv().RideStorm
if not RS then return end

local active = false
local ap, ao, att0, att1
local seat, hum, hrp
local sitConn
local wheelWelds = {}
local hiddenWheels = {}

--------------------------------------------------
-- UTILIDADES
--------------------------------------------------

local function getSeat()
    local char = Player.Character
    if not char then return end
    hum = char:FindFirstChildOfClass("Humanoid")
    hrp = char:FindFirstChild("HumanoidRootPart")
    seat = hum and hum.SeatPart
    return seat and hum and hrp
end

local function hideWheels()
    for _, v in ipairs(seat.Parent:GetDescendants()) do
        if v:IsA("BasePart") then
            local n = v.Name:lower()
            if n:find("wheel") or n:find("tire") or n:find("rim") then
                hiddenWheels[v] = v.Transparency
                v.Transparency = 1
            end
        end
    end
end

local function showWheels()
    for v, t in pairs(hiddenWheels) do
        if v then v.Transparency = t end
    end
    table.clear(hiddenWheels)
end

local function weldWheels()
    for _, v in ipairs(seat.Parent:GetDescendants()) do
        if v:IsA("BasePart") then
            local n = v.Name:lower()
            if n:find("wheel") or n:find("tire") or n:find("rim") then
                local w = Instance.new("WeldConstraint")
                w.Part0 = seat
                w.Part1 = v
                w.Parent = seat
                table.insert(wheelWelds, w)
            end
        end
    end
end

local function unweldWheels()
    for _, w in ipairs(wheelWelds) do
        if w then w:Destroy() end
    end
    table.clear(wheelWelds)
end

--------------------------------------------------
-- START / STOP
--------------------------------------------------

local function start()
    if active then return end
    if not getSeat() then return end

    active = true



    if RS.HideWheels then
        hideWheels()
    end

    weldWheels()

    att0 = Instance.new("Attachment", seat)
    att1 = Instance.new("Attachment", workspace.Terrain)

    ap = Instance.new("AlignPosition", seat)
    ap.Attachment0 = att0
    ap.Attachment1 = att1
    ap.MaxForce = math.huge
    ap.MaxVelocity = 10000
    ap.Responsiveness = 200

    ao = Instance.new("AlignOrientation", seat)
    ao.Attachment0 = att0
    ao.Attachment1 = att1
    ao.MaxTorque = math.huge
    ao.Responsiveness = 200

    local basePos = Vector3.new(
        seat.Position.X,
        RS.FlyHeight,
        seat.Position.Z
    )

    att1.WorldPosition = basePos
    att1.WorldCFrame = seat.CFrame

    sitConn = RunService.Stepped:Connect(function()
        if not RS.SpeedFarm then return end
        if hum.SeatPart ~= seat then
            hrp.CFrame = seat.CFrame
            seat:Sit(hum)
        end
    end)

    task.spawn(function()
        while RS.SpeedFarm do
            local speed = RS.SpeedKMH * 6
            local forward = att1.WorldPosition + seat.CFrame.LookVector * speed
            att1.WorldPosition = Vector3.new(forward.X, RS.FlyHeight, forward.Z)
            task.wait(0.1)
        end
    end)
end

local function stop()
    active = false

    if sitConn then sitConn:Disconnect() sitConn = nil end
    if ap then ap:Destroy() end
    if ao then ao:Destroy() end
    if att0 then att0:Destroy() end
    if att1 then att1:Destroy() end

    unweldWheels()
    showWheels()
end

--------------------------------------------------
-- LOOP PRINCIPAL
--------------------------------------------------

RunService.Heartbeat:Connect(function()
    if RS.SpeedFarm then
        if not active then start() end
    else
        if active then stop() end
    end
end)
