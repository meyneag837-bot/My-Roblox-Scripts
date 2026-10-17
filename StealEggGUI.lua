local autoStealActive = false

MainTab:CreateToggle({
   Name = "🔄 Auto Steal (ប្រើកូដចុចអក្សរ E)",
   CurrentValue = false,
   Flag = "AutoStealPromptToggle",
   Callback = function(Value)
        autoStealActive = Value
        
        if autoStealActive then
            Rayfield:Notify({Title = "Auto Steal", Content = "កំពុងស្កេនរកវត្ថុ និងបញ្ជាចុច E...", Duration = 2})
            
            task.spawn(function()
                while autoStealActive do
                    task.wait(0.1) -- សម្រាកបន្តិចកុំឱ្យទូរស័ព្ទគាំង
                    
                    local player = game.Players.LocalPlayer
                    local char = player.Character
                    
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        local rootPart = char.HumanoidRootPart
                        
                        -- រាវរកវត្ថុនៅក្នុងហ្គេម
                        for _, item in pairs(workspace:GetDescendants()) do
                            if not autoStealActive then break end 
                            
                            -- ស្វែងរកឈ្មោះវត្ថុដែលអ្នកចង់បាន (ឧទាហរណ៍៖ Egg ឬ Secret)
                            if item:IsA("BasePart") and (string.find(item.Name, "Egg") or string.find(item.Name, "Secret")) then
                                
                                -- រាវរកប្រព័ន្ធ ProximityPrompt (អក្សរ E) ដែលលាក់នៅខាងក្នុងវត្ថុនោះ
                                local prompt = item:FindFirstChildWhichIsA("ProximityPrompt", true)
                                
                                if prompt then
                                    pcall(function()
                                        -- ១. ហោះទៅឈរជិតវត្ថុនោះសិន ដើម្បីកុំឱ្យ Server ចាប់បានថាចុចពីចម្ងាយ
                                        rootPart.CFrame = item.CFrame + Vector3.new(0, 2, 0)
                                        task.wait(0.1) -- រង់ចាំបន្តិចឱ្យ Server ទទួលស្គាល់ទីតាំងថ្មី
                                        
                                        -- ២. បញ្ជាឱ្យចុចអក្សរ E ដោយស្វ័យប្រវត្តិ
                                        fireproximityprompt(prompt)
                                        
                                        -- (ជម្រើសបន្ថែម) បើ Executor ខ្លះទាមទារប៉ារ៉ាម៉ែត្របន្ថែម សូមសាកល្បងកូដនេះជំនួស៖
                                        -- fireproximityprompt(prompt, 1, true)
                                    end)
                                    
                                    task.wait(0.5) -- សម្រាកកន្លះវិនាទី មុននឹងហោះទៅចុចវត្ថុបន្ទាប់កុំឱ្យ Spam
                                end
                            end
                        end
                    end
                end
            end)
        else
            Rayfield:Notify({Title = "បញ្ឈប់", Content = "បានបញ្ឈប់ការលួចដោយចុច E។", Duration = 2})
        end
   end,
})
