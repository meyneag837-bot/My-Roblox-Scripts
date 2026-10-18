-- 1. ទាញយក Modules ពី GitHub របស់អ្នក (សូមដូរ Link ខាងក្រោមទៅជា Raw Link ពី GitHub របស់អ្នកពិតប្រាកដ)
local AutoSteal = loadstring(game:HttpGet("https://raw.githubusercontent.com/ឈ្មោះរបស់អ្នក/គម្រោង/main/AutoSteal.lua"))()
local PlayerStats = loadstring(game:HttpGet("https://raw.githubusercontent.com/ឈ្មោះរបស់អ្នក/គម្រោង/main/PlayerStats.lua"))()

-- 2. ទាញយក Rayfield Library សម្រាប់រចនា UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Mega Hub - Modular",
    LoadingTitle = "Loading Modules...",
    LoadingSubtitle = "by meyneang",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

-- ==========================================
-- ចង Form ទី 1: Auto Farm Tab
-- ==========================================
local FarmTab = Window:CreateTab("Auto Farm", 4483362458)

FarmTab:CreateToggle({
    Name = "Auto Steal Egg",
    CurrentValue = false,
    Flag = "AutoStealToggle",
    Callback = function(Value)
        -- ហៅមុខងារពីឯកសារ AutoSteal.lua មកដំណើរការ
        AutoSteal.Toggle(Value) 
    end,
})

-- ==========================================
-- ចង Form ទី 2: Player Tab
-- ==========================================
local PlayerTab = Window:CreateTab("Player Settings", 4483362458)

PlayerTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 250},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = 16,
    Flag = "SpeedSlider",
    Callback = function(Value)
        -- ហៅមុខងារពីឯកសារ PlayerStats.lua មកដំណើរការ
        PlayerStats.SetSpeed(Value)
    end,
})

PlayerTab:CreateSlider({
    Name = "Jump Power",
    Range = {50, 300},
    Increment = 1,
    Suffix = "Jump",
    CurrentValue = 50,
    Flag = "JumpSlider",
    Callback = function(Value)
        -- ហៅមុខងារពីឯកសារ PlayerStats.lua មកដំណើរការ
        PlayerStats.SetJumpPower(Value)
    end,
})

-- បន្ថែមប៊ូតុង Mobile Toggle នៅទីនេះ (កូដពីខាងលើ) ប្រសិនបើអ្នកលេងលើទូរសព្ទ...
