-- speedfarm_air.lua
-- Speed farm: ELEVAR al jugador y mover HRP en micro-pasos horizontales.
-- Protección: detecta rollback / desmontes y se detiene.

if getgenv()._RideStorm_SpeedAir_Loaded then return end
getgenv()._RideStorm_SpeedAir_Loaded = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local RS = getgenv().RideStorm or {}

-- ====== CONFIGURABLE ======
local ALTURA = 200               -- altura en studs para evitar colisiones
local STEP = 5                   -- studs por tick (ajusta para más/menos velocidad)
local DIST = 120                 -- distancia desde origen antes de invertir
local TICK_WAIT = 0.05           -- tiempo entre pasos (heartbeats usan dt, pero controlamos)
local MAX_WARN_ROLLBACK = 3      -- número de rollbacks permitidos antes de parar
local SAFETY_TIMEOUT = 8         -- segundos de chequeo si no hay seat -> parar
-- ===========================

local hbConn
local running = false

local function getHumAndHRP()
    local char = player.Character
    if not char then return nil, nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    return hum, hrp
end

local function isSeated()
    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    return hum and hum.SeatPart ~= nil
end

local function startAirFarm()
    if running then return end
    running = true

    -- Safety: wait until seat exists and player is seated
    local waited = 0
    while waited < SAFETY_TIMEOUT do
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.SeatPart then break end
        task.wait(0.2); waited = waited + 0.2
    end
    if not isSeated() then
        warn("SpeedAir: no estás sentado o seat no disponible")
        running = false
        return
    end

    local hum, hrp = getHumAndHRP()
    if not hrp then running = false; return end

    -- Inicial: elevar HRP al ALTURA deseado (mantener X/Z)
    local originPos = hrp.Position
    local elevatedPos = Vector3.new(originPos.X, ALTURA, originPos.Z)
    hrp.CFrame = CFrame.new(elevatedPos, elevatedPos + hrp.CFrame.LookVector)

    -- Guardar referencia inicial para detectar rollback
    local startPos = hrp.Position
    local traveled = 0
    local dir = 1
    local rollbackCount = 0
    local lastValid = startPos

    -- Tiempo de inactividad / safety
    local lastSeatCheck = tick()

    hbConn = RunService.Heartbeat:Connect(function(dt)
        if not (getgenv().RideStorm and getgenv().RideStorm.SpeedFarm) then
            -- parada ordenada
            hbConn:Disconnect(); hbConn = nil; running = false
            return
        end

        if not isSeated() then
            -- te bajaste -> parar
            warn("SpeedAir: te bajaste. Parando.")
            hbConn:Disconnect(); hbConn = nil; running = false
            return
        end

        local _, hrpNow = getHumAndHRP()
        if not hrpNow then
            warn("SpeedAir: HRP perdido. Parando.")
            hbConn:Disconnect(); hbConn = nil; running = false
            return
        end

        -- si server hace rollback (posición retrocede bruscamente), detectarlo
        local distFromLast = (hrpNow.Position - lastValid).Magnitude
        if distFromLast > 50 then
            rollbackCount = rollbackCount + 1
            warn("SpeedAir: posible rollback detectado ("..rollbackCount..") dist="..math.floor(distFromLast))
            if rollbackCount >= MAX_WARN_ROLLBACK then
                warn("SpeedAir: muchos rollbacks; parado por seguridad.")
                hbConn:Disconnect(); hbConn = nil; running = false
                return
            end
        else
            lastValid = hrpNow.Position
        end

        -- compute offset local (movement in XZ plane)
        local angle = tick() * 2.0 -- rotación suave; puedes cambiar
        local offset = Vector3.new(math.cos(angle) * STEP * dir, 0, math.sin(angle) * STEP * dir)

        -- new position locked at ALTURA
        local newPos = Vector3.new(hrpNow.Position.X + offset.X, ALTURA, hrpNow.Position.Z + offset.Z)

        -- apply small micro-TP (HRP only)
        -- use pcall por si server bloquea temporalmente
        pcall(function()
            hrpNow.CFrame = CFrame.new(newPos, newPos + Vector3.new(offset.X, 0, offset.Z))
        end)

        traveled = traveled + offset.Magnitude
        if traveled >= DIST then
            dir = dir * -1
            traveled = 0
        end

        task.wait(TICK_WAIT) -- ligero throttle
    end)
end

local function stopAirFarm()
    if hbConn then hbConn:Disconnect(); hbConn = nil end
    running = false
end

-- watcher: se dispara según RS.SpeedFarm flag
spawn(function()
    while true do
        task.wait(0.3)
        if not getgenv().RideStorm then break end
        if getgenv().RideStorm.SpeedFarm and not running then
            startAirFarm()
        elseif not getgenv().RideStorm.SpeedFarm and running then
            stopAirFarm()
        end
    end
end)

return true