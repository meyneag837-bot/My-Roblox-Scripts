local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({Name = "Advanced Steal Panel", LoadingTitle = "Loading...", KeySystem = false})
local PanelTab = Window:CreateTab("Steal Panel", 4483345998)

local liveItemsList = {"សូមចុចប៊ូតុងស្កេន..."}
local rawItemsData = {} -- ទុកទិន្នន័យវត្ថុពិតប្រាកដ
local selectedItemString = ""
local stealSteps = 6 -- លំនាំដើមដូចក្នុងរូបភាព

PanelTab:CreateSection("ការកំណត់ការហោះលួច (Teleport Settings)")

-- មុខងារ Instant Steal Steps ដូចក្នុងរូបភាពរបស់អ្នក
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

PanelTab:CreateSection("បញ្ជីសត្វ/វត្ថុ (Live Targets)")

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

PanelTab:CreateButton({
   Name = "🔄 ស្កេនទាញទិន្នន័យសត្វ/ស៊ុតថ្មីៗ",
   Callback = function()
        local newList = {}
        rawItemsData = {}
        
        for _, item in pairs(workspace:GetDescendants()) do
            -- ស្កេនរកវត្ថុ (អ្នកអាចកែពាក្យ Egg ទៅតាមឈ្មោះវត្ថុក្នុងហ្គេមជាក់ស្តែង)
            if item:IsA("BasePart") and (string.find(item.Name, "Egg") or string.find(item.Name, "Pet") or string.find(item.Name, "Bull") or string.find(item.Name, "Fox")) then
                
                -- កូដក្លែងធ្វើការទាញយកទិន្នន័យ លុយ និង ទម្ងន់ (បើហ្គេមមានផ្ទុក Value ទាំងនេះ)
                local valuePerSec = item:FindFirstChild("Value") and tostring(item.Value.Value) or "???"
                local weight = item:FindFirstChild("Weight") and tostring(item.Weight.Value) or "???"
                
                -- រៀបចំទម្រង់អក្សរឧទាហរណ៍: "Flaming Bull | $8.9K/s | 411.66 Kg"
                local displayText = string.format("%s | $%s/s | %s Kg", item.Name, valuePerSec, weight)
                
                table.insert(newList, displayText)
                rawItemsData[displayText] = item -- កត់ត្រាទុកដើម្បីងាយស្រួលទាញយក
            end
        end
        
        if #newList == 0 then table.insert(newList, "រកមិនឃើញវត្ថុទេ") end
        ItemDropdown:Refresh(newList)
        Rayfield:Notify({Title = "ស្កេនរួចរាល់", Content = "រកឃើញចំនួន " .. #newList .. " គោលដៅ", Duration = 3})
   end,
})

-- Function សម្រាប់ហោះជាជំហានៗ (Bypass Anti-Cheat)
local function StepTeleport(targetPart, steps)
    local player = game.Players.LocalPlayer
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local root = char.HumanoidRootPart
        local startPos = root.Position
        local targetPos = targetPart.Position
        
        -- ចែកចម្ងាយជាកង់ៗ (Steps)
        local stepVector = (targetPos - startPos) / steps
        
        for i = 1, steps do
            -- ហោះម្តងមួយកង់ៗ
            root.CFrame = CFrame.new(startPos + (stepVector * i))
            task.wait(0.1) -- រង់ចាំបន្តិចនៅរាល់ជំហាននីមួយៗ
        end
    end
end

PanelTab:CreateButton({
   Name = "🟢 ធ្វើការលួចភ្លាមៗ (INSTANT STEAL)",
   Callback = function()
        if selectedItemString == "" or selectedItemString == "សូមចុចប៊ូតុងស្កេន..." or selectedItemString == "រកមិនឃើញវត្ថុទេ" then
            return Rayfield:Notify({Title = "កំហុស", Content = "សូមរើសវត្ថុមុខសញ្ញាសិន", Duration = 2})
        end
        
        local targetItem = rawItemsData[selectedItemString]
        if targetItem and targetItem.Parent then
            Rayfield:Notify({Title = "Stealing...", Content = "កំពុងហោះទៅលួចជា " .. stealSteps .. " ជំហាន", Duration = 2})
            
            -- ហៅមុខងារហោះជាជំហានៗមកប្រើ
            StepTeleport(targetItem, stealSteps)
            
            -- ពេលហោះដល់ ទាញយកវា
            task.wait(0.2)
            pcall(function()
                targetItem.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
            end)
        else
            Rayfield:Notify({Title = "បរាជ័យ", Content = "វត្ថុនេះត្រូវគេយកបាត់ហើយ!", Duration = 2})
        end
   end,
})
