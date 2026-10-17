-- ==============================================================
-- FOXNAME HUB - ADVANCED STEAL PANEL
-- ==============================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Advanced Steal Panel",
   LoadingTitle = "Loading Bypass System...",
   LoadingSubtitle = "by Foxname",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local PanelTab = Window:CreateTab("Steal Panel", 4483345998)

-- ==========================================
-- អថេរសម្រាប់ផ្ទុកទិន្នន័យ
-- ==========================================
local liveItemsList = {"សូមចុចប៊ូតុងស្កេន..."}
local rawItemsData = {} 
local selectedItemString = ""
local stealSteps = 6 
local autoStealTargetActive = false

-- ==========================================
-- Function ហោះជាជំហានៗ (Bypass Anti-Cheat)
-- ==========================================
local function StepTeleport(targetPart, steps)
    local player = game.Players.LocalPlayer
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local root = char.HumanoidRootPart
        local startPos = root.Position
        local targetPos = targetPart.Position
        
        local stepVector = (targetPos - startPos) / steps
        
        for i = 1, steps do
            root.CFrame = CFrame.new(startPos + (stepVector * i))
            task.wait(0.1) -- រង់ចាំបន្តិចនៅរាល់ជំហាននីមួយៗ
        end
    end
end

-- ==========================================
-- ផ្នែក UI: ការកំណត់ និងបញ្ជីគោលដៅ
-- ==========================================
PanelTab:CreateSection("១. ការកំណត់ការហោះលួច (Bypass Settings)")

PanelTab:CreateSlider({
   Name = "Instant Steal Steps (ជំហានហោះសុវត្ថិភាព)",
   Range = {1, 20},
   Increment = 1,
   Suffix = " ជំហាន",
   CurrentValue = 6,
   Flag = "StealStepsSlider",
   Callback = function(Value)
        stealSteps = Value
   end,
})

PanelTab:CreateSection("២. បញ្ជីមុខសញ្ញា (Live Targets)")

local ItemDropdown = PanelTab:CreateDropdown({
   Name = "ជ្រើសរើសវត្ថុដើម្បីលួច",
   Options = liveItemsList,
   CurrentOption = {liveItemsList[1]},
   MultipleOptions = false,
   Flag = "TargetDropdown",
   Callback = function(Option)
        selectedItemString = Option[1]
   end,
})

-- ប៊ូតុងស្កេន និងតម្រៀបពីថ្លៃទៅថោក (Sort Highest Value)
PanelTab:CreateButton({
   Name = "🔄 ស្កេនទាញទិន្នន័យ (Sort: Highest Value)",
   Callback = function()
        local scannedData = {} 
        local newList = {}
        rawItemsData = {}
        
        for _, item in pairs(workspace:GetDescendants()) do
            -- កែប្រែលក្ខខណ្ឌឈ្មោះនៅទីនេះបានតាមចិត្ត (Egg, Pet, Bull, Fox...)
            if item:IsA("BasePart") and (string.find(item.Name, "Egg") or string.find(item.Name, "Secret") or string.find(item.Name, "Bull") or string.find(item.Name, "Pet")) then
                
                local rawValue = 0
                if item:FindFirstChild("Value") then
                    rawValue = tonumber(item.Value.Value) or 0
                end
                
                local rawWeight = item:FindFirstChild("Weight") and tostring(item.Weight.Value) or "0"
                local displayText = string.format("%s | $%s/s | %s Kg", item.Name, tostring(rawValue), rawWeight)
                
                table.insert(scannedData, {
                    Text = displayText,
                    Item = item,
                    SortValue = rawValue
                })
            end
        end
        
        -- រៀបចំពីធំទៅតូច
        table.sort(scannedData, function(a, b)
            return a.SortValue > b.SortValue
        end)
        
        for _, data in ipairs(scannedData) do
            table.insert(newList, data.Text)
            rawItemsData[data.Text] = data.Item 
        end
        
        if #newList == 0 then table.insert(newList, "រកមិនឃើញវត្ថុទេ") end
        ItemDropdown:Refresh(newList)
        Rayfield:Notify({Title = "ស្កេនជោគជ័យ", Content = "រៀបចំតាមតម្លៃថ្លៃបំផុតនៅខាងលើរួចរាល់!", Duration = 3})
   end,
})

PanelTab:CreateSection("៣. បញ្ជាឱ្យលួច (Execution)")

-- ប៊ូតុងលួចភ្លាមៗ (ចុចម្តងលួចម្តង)
PanelTab:CreateButton({
   Name = "🟢 ធ្វើការលួចភ្លាមៗ (INSTANT STEAL)",
   Callback = function()
        if selectedItemString == "" or selectedItemString == "សូមចុចប៊ូតុងស្កេន..." or selectedItemString == "រកមិនឃើញវត្ថុទេ" then
            return Rayfield:Notify({Title = "កំហុស", Content = "សូមរើសវត្ថុមុខសញ្ញាសិន", Duration = 2})
        end
        
        local targetItem = rawItemsData[selectedItemString]
        if targetItem and targetItem.Parent then
            Rayfield:Notify({Title = "Stealing...", Content = "កំពុងហោះទៅលួចជា " .. stealSteps .. " ជំហាន", Duration = 2})
            
            StepTeleport(targetItem, stealSteps)
            
            task.wait(0.2)
            pcall(function()
                targetItem.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
            end)
        else
            Rayfield:Notify({Title = "បរាជ័យ", Content = "វត្ថុនេះត្រូវគេយកបាត់ហើយ!", Duration = 2})
        end
   end,
})

-- Toggle សម្រាប់ Auto Steal សត្វនោះរហូតទាល់តែបិទវិញ
PanelTab:CreateToggle({
   Name = "🔄 Auto Steal (លួចសត្វនេះដោយស្វ័យប្រវត្តិ)",
   CurrentValue = false,
   Flag = "AutoStealAdvancedToggle",
   Callback = function(Value)
        autoStealTargetActive = Value
        
        if autoStealTargetActive then
            if selectedItemString == "" or selectedItemString == "សូមចុចប៊ូតុងស្កេន..." or selectedItemString == "រកមិនឃើញវត្ថុទេ" then
                Rayfield:Notify({Title = "មានកំហុស", Content = "សូមជ្រើសរើសវត្ថុពីបញ្ជីខាងលើជាមុនសិន!", Duration = 3})
                return
            end
            
            local targetInstance = rawItemsData[selectedItemString]
            local targetRealName = targetInstance and targetInstance.Name or ""
            
            if targetRealName == "" then return end
            Rayfield:Notify({Title = "Auto Steal បើកដំណើរការ", Content = "កំពុងតាមលួច: " .. targetRealName, Duration = 2})
            
            task.spawn(function()
                while autoStealTargetActive do
                    task.wait(1) 
                    
                    local player = game.Players.LocalPlayer
                    local char = player.Character
                    
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        local foundItem = false
                        
                        for _, item in pairs(workspace:GetDescendants()) do
                            if not autoStealTargetActive then break end
                            
                            if item:IsA("BasePart") and item.Name == targetRealName then
                                foundItem = true
                                StepTeleport(item, stealSteps)
                                
                                task.wait(0.2)
                                pcall(function()
                                    item.CFrame = char.HumanoidRootPart.CFrame
                                end)
                                
                                task.wait(1)
                                break 
                            end
                        end
                        if not foundItem then task.wait(2) end
                    end
                end
            end)
        else
            Rayfield:Notify({Title = "Auto Steal ត្រូវបានបិទ", Content = "បញ្ឈប់ការលួចស្វ័យប្រវត្តិ។", Duration = 2})
        end
   end,
})

Rayfield:LoadConfiguration()
