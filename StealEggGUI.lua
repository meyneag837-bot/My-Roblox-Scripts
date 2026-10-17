-- ==============================================================
-- SAFE AUTO STEAL (ANTI-CHEAT BYPASS BAC-3512)
-- ==============================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local TweenService = game:GetService("TweenService")
local player = game.Players.LocalPlayer

local Window = Rayfield:CreateWindow({
   Name = "Safe Auto Steal (Bypass)",
   LoadingTitle = "Bypassing Anti-Cheat...",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local MainTab = Window:CreateTab("Safe Farm", 4483345998)

-- ==========================================
-- Function ហោះទៅរកស៊ុតយឺតៗដោយសុវត្ថិភាព
-- ==========================================
local function SafeTween(targetCFrame)
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local root = char.HumanoidRootPart
        
        -- គណនាចម្ងាយដើម្បីកំណត់ល្បឿនហោះឱ្យសមស្រប (កុំឱ្យលឿនពេក)
        local distance = (root.Position - targetCFrame.Position).Magnitude
        local speed = 40 -- ល្បឿនហោះ (បន្ថយលេខនេះបើនៅតែ Kick)
        local timeToFly = distance / speed
        
        -- កំណត់ការហោះ
        local tweenInfo = TweenInfo.new(timeToFly, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(root, tweenInfo, {CFrame = targetCFrame})
        
        tween:Play()
        tween.Completed:Wait() -- រង់ចាំរហូតដល់ហោះដល់គោលដៅទើបដើរកូដបន្ត
    end
end

-- ==========================================
-- Toggle បញ្ជា Auto Steal
-- ==========================================
local safeAutoSteal = false

MainTab:CreateToggle({
   Name = "Safe Auto Steal (ហោះទៅយកស៊ុតយឺតៗ)",
   CurrentValue = false,
   Flag = "SafeStealToggle",
   Callback = function(Value)
        safeAutoSteal = Value
        
        if safeAutoSteal then
            Rayfield:Notify({Title = "Safe Mode", Content = "ចាប់ផ្តើមហោះទៅយកស៊ុតដោយសុវត្ថិភាព...", Duration = 3})
            
            task.spawn(function()
                while safeAutoSteal do
                    task.wait(1) -- សម្រាក 1 វិនាទីសិនមុននឹងស្វែងរកស៊ុតថ្មី
                    
                    local foundEgg = false
                    for _, item in pairs(workspace:GetDescendants()) do
                        if not safeAutoSteal then break end
                        
                        if item:IsA("BasePart") and (string.find(item.Name, "Egg") or string.find(item.Name, "Secret")) then
                            foundEgg = true
                            
                            -- ១. ហោះទៅពីលើស៊ុតដោយរលូន
                            SafeTween(item.CFrame + Vector3.new(0, 2.5, 0))
                            
                            -- ២. សម្រាក 1.5 វិនាទី នៅពេលហោះដល់ ដើម្បីបន្លំហ្គេមថាជាមនុស្សកំពុងដើររើស
                            task.wait(1.5) 
                            
                            break -- យកបានមួយហើយ ផ្តាច់រង្វិលជុំ រួចទៅស្កេនរកមួយទៀត
                        end
                    end
                    
                    if not foundEgg then
                        task.wait(2) -- បើកុំមានស៊ុត សម្រាកសិនកុំឱ្យគាំង
                    end
                end
            end)
        else
            Rayfield:Notify({Title = "បញ្ឈប់", Content = "បានផ្អាកការហោះ។", Duration = 2})
        end
   end,
})

Rayfield:LoadConfiguration()
