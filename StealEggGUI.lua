-- ==============================================================
-- FOXNAME HUB - ULTIMATE STEAL AN EGG SCRIPT
-- ==============================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Foxname Hub - Ultimate",
   LoadingTitle = "Loading Script...",
   LoadingSubtitle = "by Foxname",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false -- បានបិទប្រព័ន្ធ Key មិនឱ្យទាមទារលេខសម្ងាត់
})

-- ==============================================================
-- ផ្នែកទី ១៖ អថេរ និង FUNCTIONS គោល
-- ==============================================================
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local player = game.Players.LocalPlayer

-- ១.១ ប្រព័ន្ធការពារ Anti-AFK
local VirtualUser = game:GetService("VirtualUser")
player.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- ១.២ Function ហោះ (Tween Teleport) រួមជាមួយ Noclip ទម្លុះជញ្ជាំង
local isTweening = false
local function TweenTeleport(targetCFrame, duration)
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        isTweening = true
        local rootPart = character.HumanoidRootPart
        
        -- បើក Noclip មិនឱ្យទាក់ជញ្ជាំង
        local noclipConnection = RunService.Stepped:Connect(function()
            if isTweening then
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
        
        local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(rootPart, tweenInfo, {CFrame = targetCFrame})
        tween:Play()
        
        tween.Completed:Connect(function()
            isTweening = false
            noclipConnection:Disconnect() -- បិទ Noclip វិញពេលហោះដល់
        end)
    end
end

-- ==============================================================
-- ផ្នែកទី ២៖ បង្កើត TABS
-- ==============================================================
local MainTab = Window:CreateTab("Auto Farm", 4483345998)
local ScannerTab = Window:CreateTab("Live Scanner", 4483345998)
local PlayerTab = Window:CreateTab("Player & Misc", 4483345998)

-- ==============================================================
-- ផ្នែកទី ៣៖ MAIN TAB (មុខងារលួចទូទៅ & ទិន្នន័យ)
-- ==============================================================
-- ផ្ទាំង Live Stats
local StatTracker = MainTab:CreateParagraph({Title = "📊 ទិន្នន័យផ្ទាល់ខ្លួន (Live Stats)", Content = "កំពុងទាញយកទិន្នន័យ..."})

task.spawn(function()
    while task.wait(1) do
        if player:FindFirstChild("leaderstats") then
            local stats = player.leaderstats
            local money = stats:FindFirstChild("Money") or stats:FindFirstChild("Coins")
            local eggs = stats:FindFirstChild("Eggs")
            
            local moneyVal = money and tostring(money.Value) or "0"
            local eggsVal = eggs and tostring(eggs.Value) or "0"
            
            local displayString = string.format("<font color='#FFD700'>💰 លុយ: %s</font>\n<font color='#FFB6C1'>🥚 ពង: %s</font>", moneyVal, eggsVal)
            StatTracker:Set({Title = "📊 ទិន្នន័យផ្ទាល់ខ្លួន (Live Stats)", Content = displayString})
        end
    end
end)

-- ការកំណត់ និងបញ្ជា Auto Steal
local selectedArea = "Spawn"
local selectedRarity = "Common"
local autoStealActive = false

MainTab:CreateDropdown({
   Name = "ជ្រើសរើសតំបន់ (Area)",
   Options = {"Spawn", "Desert", "Snow", "Volcano", "Heaven"},
   CurrentOption = {"Spawn"},
   Flag = "AreaDrop",
   Callback = function(Option) selectedArea = Option[1] end,
})

MainTab:CreateDropdown({
   Name = "ជ្រើសរើសកម្រិត (Rarity)",
   Options = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythical", "Secret", "Divine"},
   CurrentOption = {"Common"},
   Flag = "RarityDrop",
   Callback = function(Option) selectedRarity = Option[1] end,
})

MainTab:CreateToggle({
   Name = "Auto Steal (លួចតាមតំបន់ & កម្រិត)",
   CurrentValue = false,
   Flag = "StealToggle",
   Callback = function(Value)
        autoStealActive = Value
        if autoStealActive then
            task.spawn(function()
                while autoStealActive do
                    task.wait(0.1)
                    local character = player.Character
                    if character and character:FindFirstChild("HumanoidRootPart") then
                        local rootPart = character.HumanoidRootPart
                        for _, item in pairs(workspace:GetDescendants()) do
                            if not autoStealActive then break end 
                            if item:IsA("BasePart") and string.find(item.Name, "Egg") then
                                if item.Parent and item.Parent.Name == selectedArea then
                                    if item:FindFirstChild("Rarity") and item.Rarity.Value == selectedRarity then
                                        pcall(function() item.CFrame = rootPart.CFrame end)
                                        task.wait(0.05)
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
   end,
})

-- ==============================================================
-- ផ្នែកទី ៤៖ SCANNER TAB (ស្កេន និង Teleport ហោះទៅរកស៊ុត)
-- ==============================================================
local selectedLiveEgg = ""
local liveEggsList = {"មិនទាន់ស្កេន..."}

local LiveEggDropdown = ScannerTab:CreateDropdown({
   Name = "ជ្រើសរើសស៊ុត (Select Live Egg)",
   Options = liveEggsList,
   CurrentOption = {liveEggsList[1]},
   Flag = "LiveEggDrop",
   Callback = function(Option) selectedLiveEgg = Option[1] end,
})

ScannerTab:CreateButton({
   Name = "🔄 ស្កេនទាញឈ្មោះស៊ុតលើ Map ថ្មីៗ",
   Callback = function()
        local foundEggs = {}
        local eggDict = {} 
        for _, item in pairs(workspace:GetDescendants()) do
            if item:IsA("BasePart") and (string.find(item.Name, "Egg") or string.find(item.Name, "Secret")) then
                if not eggDict[item.Name] then
                    eggDict[item.Name] = true
                    table.insert(foundEggs, item.Name)
                end
            end
        end
        if #foundEggs == 0 then table.insert(foundEggs, "រកមិនឃើញស៊ុតទេ") end
        LiveEggDropdown:Refresh(foundEggs)
        Rayfield:Notify({Title = "ជោគជ័យ", Content = "ស្កេនឃើញ " .. #foundEggs .. " ប្រភេទ", Duration = 3})
   end,
})

ScannerTab:CreateButton({
   Name = "🚀 ហោះទៅរកស៊ុតនេះ (Tween Teleport)",
   Callback = function()
        if selectedLiveEgg == "" or selectedLiveEgg == "មិនទាន់ស្កេន..." then return end
        for _, item in pairs(workspace:GetDescendants()) do
            if item:IsA("BasePart") and item.Name == selectedLiveEgg then
                TweenTeleport(item.CFrame + Vector3.new(0, 3, 0), 3) -- ហោះប្រើពេល ៣ វិនាទី
                Rayfield:Notify({Title = "កំពុងហោះ...", Content = "ហោះទៅរក: " .. selectedLiveEgg, Duration = 3})
                break
            end
        end
   end,
})

-- ==============================================================
-- ផ្នែកទី ៥៖ PLAYER TAB (ល្បឿន និងសន្សំថ្ម)
-- ==============================================================
PlayerTab:CreateSection("ល្បឿនរត់ (WalkSpeed)")

PlayerTab:CreateButton({
   Name = "កំណត់ល្បឿនរត់ 128",
   Callback = function()
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = 128
        end
   end,
})

PlayerTab:CreateButton({
   Name = "ល្បឿនធម្មតា 16",
   Callback = function()
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = 16
        end
   end,
})

PlayerTab:CreateSection("ប្រព័ន្ធទប់ការគាំង (Optimization)")

PlayerTab:CreateButton({
   Name = "ដំណើរការ FPS Booster (បន្ថយក្រាហ្វិក)",
   Callback = function()
        local lighting = game:GetService("Lighting")
        lighting.GlobalShadows = false
        lighting.FogEnd = 9e9
        
        for _, obj in pairs(workspace:GetDescendants()) do
            pcall(function()
                if obj:IsA("BasePart") then obj.Material = Enum.Material.SmoothPlastic end
                if obj:IsA("Decal") or obj:IsA("Texture") or obj:IsA("ParticleEmitter") then obj:Destroy() end
            end)
        end
        Rayfield:Notify({Title = "FPS Booster", Content = "ក្រាហ្វិកត្រូវបានបន្ថយ!", Duration = 3})
   end,
})

Rayfield:LoadConfiguration()
Rayfield:Notify({Title = "Foxname Hub", Content = "Script បានដំណើរការជោគជ័យពេញលេញ!", Duration = 5})
