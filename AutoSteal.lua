local StealModule = {}
StealModule.Active = false

function StealModule.Toggle(state)
    StealModule.Active = state
    if state then
        task.spawn(function()
            while StealModule.Active do
                task.wait(1) -- រង់ចាំ 1 វិនាទី
                local player = game.Players.LocalPlayer
                local character = player.Character
                -- (អ្នកអាចយកកូដ Teleport ទៅលួចស៊ុតពីខាងលើមកដាក់នៅទីនេះ)
                print("កំពុងដំណើរការ Auto Steal...")
            end
        end)
    end
end

return StealModule -- ត្រូវតែមានពាក្យ return នេះនៅខាងក្រោមគេ
