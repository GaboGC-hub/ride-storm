-- RideStorm Hub (estable)

-- Multi-PlaceId (opcional)
local SupportedPlaces = {
    [1234567890] = true, -- ejemplo
    [game.PlaceId] = true -- permite el actual
}

if not SupportedPlaces[game.PlaceId] then
    warn("RideStorm: PlaceId no soportado")
    return
end

-- Cargar Rayfield (FORMA OFICIAL)
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- Crear ventana
local Window = Rayfield:CreateWindow({
    Name = "RideStorm 🏍️",
    LoadingTitle = "RideStorm",
    LoadingSubtitle = "Auto Delivery",
    ConfigurationSaving = {
        Enabled = false
    }
})

-- Tabs
local DeliveryTab = Window:CreateTab("🚚 Delivery")
local TeleportTab = Window:CreateTab("📍 Teleports")
local MiscTab = Window:CreateTab("🎲 Misc")

-- Estado global simple
getgenv().RideStorm = {
    Farming = false,
    Money = 0
}

-- Labels
local moneyLabel = DeliveryTab:CreateLabel("💰 Dinero ganado: $0")

-- Toggle Autofarm
DeliveryTab:CreateToggle({
    Name = "Auto Delivery Farm",
    CurrentValue = false,
    Callback = function(state)
        getgenv().RideStorm.Farming = state
        if state then
            loadstring(game:HttpGet(
                "https://raw.githubusercontent.com/GaboGC-hub/ride-storm/main/autofarm.lua"
            ))()
        end
    end
})

-- Exponer para autofarm
getgenv().RideStorm.UpdateMoney = function(amount)
    getgenv().RideStorm.Money += amount
    moneyLabel:Set("💰 Dinero ganado: $" .. getgenv().RideStorm.Money)
end

-- Teleports (ejemplo)
TeleportTab:CreateButton({
    Name = "Ir a Delivery Job",
    Callback = function()
        local hrp = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp and workspace:FindFirstChild("DeliveryJob") then
            hrp.CFrame = workspace.DeliveryJob.BoxPickingJob.PickupBox.CFrame
        end
    end
})

-- Misc
MiscTab:CreateButton({
    Name = "Reiniciar contador",
    Callback = function()
        getgenv().RideStorm.Money = 0
        moneyLabel:Set("💰 Dinero ganado: $0")
    end
})

Rayfield:Notify({
    Title = "RideStorm",
    Content = "Hub cargado correctamente",
    Duration = 4
})
