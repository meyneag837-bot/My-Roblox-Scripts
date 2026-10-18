local PlayerModule = {}

function PlayerModule.SetSpeed(speedValue)
    local player = game.Players.LocalPlayer
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = speedValue
    end
end

function PlayerModule.SetJumpPower(jumpValue)
    local player = game.Players.LocalPlayer
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.UseJumpPower = true
        player.Character.Humanoid.JumpPower = jumpValue
    end
end

return PlayerModule
