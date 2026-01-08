-- =====================================================
-- 🏍️ RideStorm Hub | FINAL ESTABLE
-- =====================================================

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()

-- LOAD RAYFIELD (OFICIAL)
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- WINDOW
local Window = Rayfield:CreateWindow({
    Name = "RideStorm 🏍️",
    LoadingTitle = "RideStorm",
    LoadingSubtitle = "Stable Edition",
    ConfigurationSaving = { Enabled = false }
})

-- TABS
local DeliveryTab = Window:CreateTab("🚚 Delivery")
local TeleportTab = Window:CreateTab("📍 Teleports")
local PlayerTab   = Window:CreateTab("👤 Player")
local MiscTab     = Window:CreateTab("🎲 Misc")

-- GLOBAL STATE
getgenv().RideStorm = {
    SpeedFarm = false,
    BoxFarm = false,
    Noclip = false,
    AntiAFK = true,
    StartMoney = nil
}
local RS = getgenv().RideStorm

-- =========================
-- MONEY (REAL)
-- =========================
local function getMoney()
    local ls = player:FindFirstChild("leaderstats")
    if not ls then return end
    return ls:FindFirstChild("Cash") or ls:FindFirstChild("Money")
end

-- =========================
-- VEHICLE HELPERS
-- =========================
local function getSeat()
    char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and hum.SeatPart and hum.SeatPart:IsA("VehicleSeat") then
        return hum.SeatPart
    end
end

-- =========================
-- SPEED FARM (REAL)
-- =========================
local TARGET_KMH = 120
local TARGET_STUDS = TARGET_KMH * 1.11

RunService.Heartbeat:Connect(function()
    if RS.SpeedFarm then
        local seat = getSeat()
        if seat then
            seat.ThrottleFloat = 1
            seat.SteerFloat = 0
        end
    end

    -- NOCLIP TOTAL
    if RS.Noclip and char then
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end
end)

-- =========================
-- AUTO DELIVERY BOX FARM
-- =========================
task.spawn(function()
    while task.wait(0.2) do
        if RS.BoxFarm then
            local job = workspace:FindFirstChild("DeliveryJob")
            if not job then
                -- TP a Truckers Bay
                local map = workspace:FindFirstChild("JOB1")
                if map then
                    local part = map:FindFirstChildWhichIsA("BasePart", true)
                    if part then
                        char:WaitForChild("HumanoidRootPart").CFrame = part.CFrame + Vector3.new(0,5,0)
                        task.wait(2)
                    end
                end
            else
                local box = job.BoxPickingJob:FindFirstChild("PickupBox")
                local drop = job.BoxPickingJob.Job:FindFirstChild("Part")

                if box and drop then
                    local hrp = char:WaitForChild("HumanoidRootPart")
                    hrp.CFrame = box.CFrame + Vector3.new(0,3,0)
                    task.wait(0.15)
                    fireproximityprompt(box.PickupPrompt)

                    hrp.CFrame = drop.CFrame + Vector3.new(0,3,0)
                    task.wait(0.15)
                    fireproximityprompt(drop.ProximityPrompt)
                end
            end
        end
    end
end)

-- =========================
-- ANTI AFK
-- =========================
player.Idled:Connect(function()
    if RS.AntiAFK then
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end
end)

-- =========================
-- UI – DELIVERY
-- =========================
DeliveryTab:CreateToggle({
    Name = "🏍️ Auto Speed Farm",
    CurrentValue = false,
    Callback = function(v)
        RS.SpeedFarm = v
        local money = getMoney()
        if v and money then
            RS.StartMoney = money.Value
        end
    end
})

DeliveryTab:CreateToggle({
    Name = "📦 Auto Delivery (Caja)",
    CurrentValue = false,
    Callback = function(v)
        RS.BoxFarm = v
    end
})

local moneyLabel = DeliveryTab:CreateLabel("💰 Dinero ganado: $0")

task.spawn(function()
    while task.wait(1) do
        local money = getMoney()
        if RS.StartMoney and money then
            moneyLabel:Set("💰 Dinero ganado: $" .. (money.Value - RS.StartMoney))
        end
    end
end)

DeliveryTab:CreateButton({
    Name = "Reiniciar contador",
    Callback = function()
        local money = getMoney()
        if money then
            RS.StartMoney = money.Value
            moneyLabel:Set("💰 Dinero ganado: $0")
        end
    end
})

-- =========================
-- TELEPORTS (SEGUROS)
-- =========================
local Teleports = {
    {"Irish Islands","mapa2"},
    {"Alp Mountains","mapa3"},
    {"Track / Drag Strip","mapa4"},
    {"Highway","mapa5"},
    {"Stello Pass","mapa6"},
    {"Spawn","mapa7"},
    {"Canyons / Route 66","mapa8"},
    {"Sunset Beach","mapa9"},
    {"The Pit","mapa1"},
    {"Enduro Course","mapa10"},
    {"The States","mapa11"},
    {"Isle of Man TT","mapa12"},
    {"Vintage Islands","mapa13"},
    {"Truckers Bay (JOB)","JOB1"}
}

for _, tp in ipairs(Teleports) do
    TeleportTab:CreateButton({
        Name = tp[1],
        Callback = function()
            local map = workspace:WaitForChild(tp[2], 5)
            if not map then return end
            local part = map:FindFirstChildWhichIsA("BasePart", true)
            if part then
                char:WaitForChild("HumanoidRootPart").CFrame = part.CFrame + Vector3.new(0,5,0)
            end
        end
    })
end

-- =========================
-- PLAYER
-- =========================
PlayerTab:CreateToggle({
    Name = "Noclip (total)",
    CurrentValue = false,
    Callback = function(v)
        RS.Noclip = v
    end
})

PlayerTab:CreateToggle({
    Name = "Anti AFK",
    CurrentValue = true,
    Callback = function(v)
        RS.AntiAFK = v
    end
})

Rayfield:Notify({
    Title = "RideStorm",
    Content = "Hub cargado correctamente",
    Duration = 4
})
