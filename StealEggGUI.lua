-- ==============================================================
-- FOXNAME HUB - ULTIMATE STEAL SCRIPT (SAFE BYPASS)
-- ==============================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local player = game.Players.LocalPlayer

local Window = Rayfield:CreateWindow({
   Name = "Foxname Hub - Ultimate Bypass",
   LoadingTitle = "Loading Bypasses...",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

-- ==============================================================
-- ១. ប្រព័ន្ធការពារ ANTI-AFK
-- ==============================================================
local VirtualUser = game:GetService("VirtualUser")
player.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- ==============================================================
-- ២. FUNCTION ហោះសុវត្ថិភាព (TWEEN + NOCLIP)
-- ==============================================================
local function SafeTween(targetCFrame, speed)
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local root = char.HumanoidRootPart
        local distance = (root.Position - targetCFrame.Position).Magnitude
        local timeToFly = distance / (speed or 40) -- ល្បឿនលំនាំដើម ៤០
        
        local tweenInfo = TweenInfo.new(timeToFly, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(root, tweenInfo, {CFrame = targetCFrame})
        
        local noclipConnection = RunService.Stepped:Connect(function()
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end)
        
        tween:Play()
        tween.Completed:Wait()
        
        if noclipConnection then noclipConnection:Disconnect() end
    end
end

-- ==============================================================
-- ៣. បង្កើត TABS
-- ==============================================================
local MainTab = Window:CreateTab("Auto Farm", 4483345998)
local ScannerTab = Window:CreateTab("Live Scanner", 4483345998)
local MiscTab = Window:CreateTab("Misc", 4483345998)

-- ==============================================================
-- ៤. មុខងារ AUTO STEAL ទូទៅ (Main Tab)
-- ==============================================================
local autoStealActive = false
local stealMethod = "ProximityPrompt (អក្សរ E)"

MainTab:CreateSection("ការកំណត់ការលួច")

MainTab:CreateDropdown({
   Name = "ជ្រើសរើសវិធីសាស្ត្រលួច (Method)",
   Options = {"ProximityPrompt (អក្សរ E)", "TouchInterest (ប៉ះ)", "CFrame (ទាញមកជិត)"},
   CurrentOption = {"ProximityPrompt (អក្សរ E)"},
   MultipleOptions = false,
   Flag = "MethodDrop",
   Callback = function(Option) stealMethod = Option[1] end,
})

MainTab:CreateToggle({
   Name = "🔄 Auto Steal (គ្រប់ស៊ុត/វត្ថុ)",
   CurrentValue = false,
   Flag = "AutoStealToggle",
   Callback = function(Value)
        autoStealActive = Value
        if autoStealActive then
            Rayfield:Notify({Title = "Auto Steal", Content = "កំពុងលួចតាមវិធី: " .. stealMethod, Duration = 2})
            task.spawn(function()
                while autoStealActive do
                    task.wait(0.5) 
                    local char = player.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        local rootPart = char.HumanoidRootPart
                        
                        for _, item in pairs(workspace:GetDescendants()) do
                            if not autoStealActive then break end 
                            
                            -- កំណត់ឈ្មោះវត្ថុដែលចង់ស្វែងរក
                            if item:IsA("BasePart") and (string.find(item.Name, "Egg") or string.find(item.Name, "Secret") or string.find(item.Name, "Bull")) then
                                
                                pcall(function()
                                    if stealMethod == "ProximityPrompt (អក្សរ E)" then
                                        local prompt = item:FindFirstChildWhichIsA("ProximityPrompt", true)
                                        if prompt then
                                            SafeTween(item.CFrame + Vector3.new(0, 3, 0), 60)
                                            task.wait(0.2)
                                            fireproximityprompt(prompt)
                                        end
                                    elseif stealMethod == "TouchInterest (ប៉ះ)" then
                                        if item:FindFirstChild("TouchInterest") then
                                            firetouchinterest(rootPart, item, 0)
                                            task.wait(0.05)
                                            firetouchinterest(rootPart, item, 1)
                                        end
                                    else
                                        item.CFrame = rootPart.CFrame
                                    end
                                end)
                                task.wait(0.5)
                            end
                        end
                    end
                end
            end)
        end
   end,
})

-- ==============================================================
-- ៥. មុខងារ LIVE SCANNER & SPECIFIC STEAL (Scanner Tab)
-- ==============================================================
local liveItemsList = {"សូមចុចប៊ូតុងស្កេន..."}
local selectedLiveItem = ""

ScannerTab:CreateSection("ស្កេនរកវត្ថុផ្ទាល់ៗ")

local LiveDropdown = ScannerTab:CreateDropdown({
   Name = "ជ្រើសរើសវត្ថុដើម្បីលួច",
   Options = liveItemsList,
   CurrentOption = {liveItemsList[1]},
   MultipleOptions = false,
   Flag = "LiveDrop",
   Callback = function(Option) selectedLiveItem = Option[1] end,
})

ScannerTab:CreateButton({
   Name = "🔄 ស្កេនទាញឈ្មោះវត្ថុថ្មីៗ",
   Callback = function()
        local foundItems = {}
        local itemDict = {} 
        for _, item in pairs(workspace:GetDescendants()) do
            if item:IsA("BasePart") and (string.find(item.Name, "Egg") or string.find(item.Name, "Secret") or string.find(item.Name, "Bull")) then
                if not itemDict[item.Name] then
                    itemDict[item.Name] = true
                    table.insert(foundItems, item.Name)
                end
            end
        end
        if #foundItems == 0 then table.insert(foundItems, "រកមិនឃើញវត្ថុទេ") end
        LiveDropdown:Refresh(foundItems)
        Rayfield:Notify({Title = "ស្កេនរួចរាល់", Content = "រកឃើញ " .. #foundItems .. " ប្រភេទ!", Duration = 3})
   end,
})

ScannerTab:CreateButton({
   Name = "🚀 ហោះទៅលួចវត្ថុនេះមួយដង (Tween)",
   Callback = function()
        if selectedLiveItem == "" or selectedLiveItem == "សូមចុចប៊ូតុងស្កេន..." then return end
        for _, item in pairs(workspace:GetDescendants()) do
            if item:IsA("BasePart") and item.Name == selectedLiveItem then
                SafeTween(item.CFrame + Vector3.new(0, 3, 0), 50)
                task.wait(0.2)
                
                -- ព្យាយាមចុច E បើមាន
                local prompt = item:FindFirstChildWhichIsA("ProximityPrompt", true)
                if prompt then fireproximityprompt(prompt) end
                
                break
            end
        end
   end,
})

-- ==============================================================
-- ៦. មុខងារ MISC (ល្បឿន & កាត់បន្ថយគាំង)
-- ==============================================================
MiscTab:CreateButton({
   Name = "ដំណើរការ FPS Booster (បន្ថយក្រាហ្វិក)",
   Callback = function()
        local lighting = game:GetService("Lighting")
        lighting.GlobalShadows = false
        for _, obj in pairs(workspace:GetDescendants()) do
            pcall(function()
                if obj:IsA("BasePart") then obj.Material = Enum.Material.SmoothPlastic end
                if obj:IsA("Decal") or obj:IsA("Texture") then obj:Destroy() end
            end)
        end
        Rayfield:Notify({Title = "FPS Booster", Content = "ហ្គេមនឹងលែងសូវគាំងទៀតហើយ!", Duration = 3})
   end,
})

MiscTab:CreateButton({
   Name = "កំណត់ល្បឿនរត់ 128",
   Callback = function()
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = 128
        end
   end,
})

Rayfield:LoadConfiguration()
Rayfield:Notify({Title = "Foxname Hub", Content = "Script ដំណើរការជោគជ័យពេញលេញ! 🛡️ Anti-AFK សកម្ម", Duration = 5})
