-- =============================
-- 🏍️ SPEED FARM OPTIMIZADO (OSCILANTE)
-- =============================

local SPEED = 300          -- studs/s (no tocar si ya paga bien)
local DISTANCE = 60        -- studs de ida y vuelta (corto = seguro)

local startPos = nil
local direction = 1

RunService.Heartbeat:Connect(function()
    if not getgenv().RideStorm.SpeedFarm then return end

    local char = player.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or not hum.SeatPart then return end

    local root = hum.SeatPart.Parent.PrimaryPart or hum.SeatPart
    if not root then return end

    if not startPos then
        startPos = root.Position
    end

    -- dirección fija
    local dir = root.CFrame.LookVector * direction

    -- velocidad constante (lo que paga)
    root.AssemblyLinearVelocity = Vector3.new(
        dir.X * SPEED,
        0,
        dir.Z * SPEED
    )

    root.AssemblyAngularVelocity = Vector3.zero

    -- invertir dirección si se aleja mucho
    if (root.Position - startPos).Magnitude >= DISTANCE then
        direction *= -1
        startPos = root.Position
    end
end)
