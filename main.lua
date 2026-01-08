-- =============================
-- 🚚 DELIVERY UI (MEJORADA)
-- =============================

-- 🔧 SECCIÓN: CONTROL
DeliveryTab:CreateSection("⚙️ Control")

DeliveryTab:CreateToggle({
    Name = "🚚 Auto Delivery Farm",
    CurrentValue = false,
    Callback = function(state)
        getgenv().RideStorm.Farming = state
        if state then
            teleportTo("JOB1") -- fuerza carga del mapa
            task.wait(1.5)
            loadstring(game:HttpGet(
                "https://raw.githubusercontent.com/GaboGC-hub/ride-storm/main/autofarm.lua"
            ))()
        end
    end
})

-- 📊 SECCIÓN: GANANCIAS
DeliveryTab:CreateSection("💰 Ganancias de la sesión")

local moneyLabel = DeliveryTab:CreateLabel("💰 Dinero ganado: $0")

DeliveryTab:CreateButton({
    Name = "🔄 Reiniciar contador",
    Callback = function()
        hookMoney()
        Rayfield:Notify({
            Title = "RideStorm",
            Content = "Contador reiniciado",
            Duration = 2
        })
    end
})
