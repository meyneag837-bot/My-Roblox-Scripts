-- ==============================================================
-- Foxname Hub - Steal An Egg Script (Rayfield Library)
-- ==============================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- ១. បង្កើតផ្ទាំង Window និងប្រព័ន្ធ Key
local Window = Rayfield:CreateWindow({
   Name = "Foxname Hub - Premium",
   LoadingTitle = "Loading Foxname Script...",
   LoadingSubtitle = "by Foxname",
   ConfigurationSaving = {
      Enabled = false,
      FolderName = "FoxnameScript",
      FileName = "FoxnameHub"
   },
   Discord = {
      Enabled = false, 
      Invite = "noinvitelink", 
      RememberJoins = true 
   },
   KeySystem = true, -- បើកប្រព័ន្ធ Key
   KeySettings = {
      Title = "Foxname Hub",
      Subtitle = "Key System",
      Note = "សូមប្រើប្រាស់ Key: Foxname2026 ដើម្បីចូល",
      FileName = "FoxnameHubKey",
      SaveKey = true, 
      GrabKeyFromSite = false, 
      Key = {"Foxname2026"} -- Key សម្រាប់ចូល
   }
})

-- ២. លោត Notification ពេលចូលជោគជ័យ
Rayfield:Notify({
   Title = "ចូលជោគជ័យ!",
   Content = "អ្នកបានវាយ Key ត្រឹមត្រូវ! សូមស្វាគមន៍មកកាន់ Foxname Hub.",
   Duration = 5,
   Image = 4483345998,
})

-- ៣. បង្កើត Tabs
local MainTab = Window:CreateTab("Auto Farm", 4483345998)
local PlayerTab = Window:CreateTab("Player Settings", 4483345998)

-- ៤. បង្កើតអថេរសម្រាប់ផ្ទុកទិន្នន័យ
local selectedArea = "Spawn"
local selectedRarity = "Common"
local autoStealActive = false
local autoStealSecretActive = false

-- ៥. Function គោលសម្រាប់លួចស៊ុត
local function StealTargetEgg(targetName, targetArea, targetRarity)
    local player = game.Players.LocalPlayer
    local character = player.Character
    if not (character and character:FindFirstChild("HumanoidRootPart")) then return end
    local rootPart = character.HumanoidRootPart
    
    for _, item in pairs(workspace:GetDescendants()) do
        -- ឆែកឈ្មោះ (យកទាំង Egg ធម្មតា និងឈ្មោះ Secret Egg ផ្សេងៗ)
        if item:IsA("BasePart") and (item.Name == targetName or (targetName == "Secret Egg" and (item.Name == "Secret" or item.Name == "SecretEgg"))) then
            
            -- ឆែកតំបន់ និង កម្រិត
            if targetArea and item.Parent and item.Parent.Name ~= targetArea then continue end
            if targetRarity and item:FindFirstChild("Rarity") and item.Rarity.Value ~= targetRarity then continue end
            
            -- ទាញយកស៊ុត
            item.CFrame = rootPart.CFrame
            
            -- លោតសារអបអរ បើបានស៊ុតកម្រិតកំពូល
            if targetName == "Secret Egg" or targetRarity == "Divine" or targetRarity == "Eternal" or targetRarity == "Secret" then
                Rayfield:Notify({
                   Title = "🎉 អបអរសាទរ!",
                   Content = "អ្នកទទួលបានស៊ុតកម្រិតកំពូល!",
                   Duration = 3,
                   Image = 4483345998,
                })
            end
            
            task.wait(0.05)
        end
    end
end

-- ==============================================================
-- ផ្នែក MAIN TAB (មុខងារលួចស៊ុត)
-- ==============================================================
MainTab:CreateSection("ការកំណត់ (Settings)")

MainTab:CreateDropdown({
   Name = "Areas to Steal (តំបន់)",
   Options = {"Spawn", "Desert", "Snow", "Volcano", "Heaven"},
   CurrentOption = {"Spawn"},
   MultipleOptions = false,
   Flag = "AreaDropdown", 
   Callback = function(Option)
        selectedArea = Option[1]
   end,
})

MainTab:CreateDropdown({
   Name = "Egg Rarities (កម្រិតស៊ុត)",
   Options = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythical", "Secret", "Eternal", "Divine"},
   CurrentOption = {"Common"},
   MultipleOptions = false,
   Flag = "RarityDropdown", 
   Callback = function(Option)
        selectedRarity = Option[1]
   end,
})

MainTab:CreateSection("មុខងារលួច (Auto Steal)")

MainTab:CreateToggle({
   Name = "Auto Steal Selected Eggs",
   CurrentValue = false,
   Flag = "AutoStealToggle", 
   Callback = function(Value)
        autoStealActive = Value
        if Value then Rayfield:Notify({ Title = "ប្រព័ន្ធដំណើរការ", Content = "កំពុងស្វែងរកស៊ុត...", Duration = 2 }) end
        
        if autoStealActive then
            task.spawn(function()
                while autoStealActive do
                    task.wait(0.1)
                    StealTargetEgg("Egg", selectedArea, selectedRarity)
                end
            end)
        end
   end,
})

MainTab:CreateToggle({
   Name = "Auto Steal Secret Egg (គ្រប់តំបន់)",
   CurrentValue = false,
   Flag = "AutoStealSecretToggle", 
   Callback = function(Value)
        autoStealSecretActive = Value
        if Value then Rayfield:Notify({ Title = "ប្រព័ន្ធដំណើរការ", Content = "កំពុងស្វែងរក Secret Egg...", Duration = 2 }) end
        
        if autoStealSecretActive then
            task.spawn(function()
                while autoStealSecretActive do
                    task.wait(0.1)
                    -- ដាក់ nil ដើម្បីឱ្យវាលួចគ្រប់តំបន់ និងគ្រប់កម្រិត
                    StealTargetEgg("Secret Egg", nil, nil) 
                end
            end)
        end
   end,
})

-- ==============================================================
-- ផ្នែក PLAYER TAB (មុខងារតួអង្គ)
-- ==============================================================
PlayerTab:CreateSection("ល្បឿនរត់ (WalkSpeed)")

PlayerTab:CreateButton({
   Name = "រត់លឿន (Speed * 128)",
   Callback = function()
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = 128
            Rayfield:Notify({ Title = "ល្បឿន", Content = "បានដំឡើងល្បឿនទៅ 128", Duration = 2 })
        end
   end,
})

PlayerTab:CreateButton({
   Name = "ល្បឿនធម្មតា (Speed 16)",
   Callback = function()
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = 16
        end
   end,
})

-- ចំណុចបញ្ចប់នៃការរៀបចំ UI របស់ Rayfield
Rayfield:LoadConfiguration()
