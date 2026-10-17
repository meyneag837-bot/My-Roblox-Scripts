-- ទាញយក Orion UI Library
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

-- បង្កើតផ្ទាំង Window ធំ (កំណត់ឈ្មោះដូចក្នុងរូប)
local Window = OrionLib:MakeWindow({
    Name = "Foxname - Steal An Egg", 
    HidePremium = true, 
    SaveConfig = false, 
    IntroText = "Loading Foxname Script..."
})

-- ==========================================
-- បង្កើត Tabs នៅខាងឆ្វេងដៃ (ដូចក្នុងរូបភាព)
-- ==========================================
local HomeTab = Window:MakeTab({ Name = "Home", Icon = "rbxassetid://4483345998", PremiumOnly = false })
local DiscordTab = Window:MakeTab({ Name = "Discord", Icon = "rbxassetid://4483345998", PremiumOnly = false })
local MainTab = Window:MakeTab({ Name = "Main", Icon = "rbxassetid://4483345998", PremiumOnly = false })
local MiscTab = Window:MakeTab({ Name = "Misc", Icon = "rbxassetid://4483345998", PremiumOnly = false })

-- ==========================================
-- បន្ថែមមុខងារទៅក្នុង Tab "Main"
-- ==========================================
MainTab:AddLabel("🥚 Auto Steal Egg")

-- Dropdown សម្រាប់ជ្រើសរើសទីតាំង (Areas to Steal)
MainTab:AddDropdown({
    Name = "Areas to Steal",
    Default = "Spawn",
    Options = {"Spawn", "Desert", "Snow", "Volcano", "Heaven"},
    Callback = function(Value)
        print("បានជ្រើសរើសទីតាំង: " .. Value)
    end    
})

-- Dropdown សម្រាប់ជ្រើសរើសកម្រិតស៊ុត (Egg Rarities to Steal)
MainTab:AddDropdown({
    Name = "Egg Rarities to Steal",
    Default = "Common",
    Options = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythical"},
    Callback = function(Value)
        print("បានជ្រើសរើសកម្រិតស៊ុត: " .. Value)
    end    
})

-- Toggle សម្រាប់ Auto Steal Selected Eggs
local autoSteal = false
MainTab:AddToggle({
    Name = "Auto Steal Selected Eggs",
    Default = false,
    Callback = function(Value)
        autoSteal = Value
        if autoSteal then
            print("កំពុងដំណើរការ Auto Steal...")
            -- កូដសម្រាប់ទាញស៊ុតមកជិតតួអង្គ (Loop)
            task.spawn(function()
                while autoSteal do
                    task.wait(0.5)
                    -- ដាក់កូដ Teleport ស៊ុតនៅទីនេះ
                end
            end)
        else
            print("បានបិទ Auto Steal")
        end
    end    
})

-- Toggle សម្រាប់ Auto Steal Secret Egg
MainTab:AddToggle({
    Name = "Auto Steal Secret Egg",
    Default = false,
    Callback = function(Value)
        print("Auto Steal Secret Egg ត្រូវបានប្តូរទៅ: ", Value)
    end    
})

-- ==========================================
-- បន្ថែមមុខងារទៅក្នុង Tab "Misc" (បញ្ចូលល្បឿនដែលអ្នកចង់បាន)
-- ==========================================
MiscTab:AddLabel("🏃 Player Settings")

MiscTab:AddButton({
    Name = "Speed * 128 (រត់លឿន)",
    Callback = function()
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = 128
            print("ល្បឿនត្រូវបានកំណត់ទៅ 128!")
        end
      end    
})

MiscTab:AddButton({
    Name = "ល្បឿនធម្មតាវិញ (Speed 16)",
    Callback = function()
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = 16
        end
      end    
})

-- បញ្ចប់ការរៀបចំផ្ទាំង UI
OrionLib:Init()
