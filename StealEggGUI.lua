-- ============================================================================
-- File: StealEggGUI.lua (GitHub Raw All-in-One Script for Roblox Studio)
-- Repo: https://raw.githubusercontent.com/meyneag837-bot/My-Roblox-Scripts/refs/heads/main/StealEggGUI.lua
-- ============================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- ============================================================================
-- ផ្នែកទី ១៖ ប្រសិនបើកូដនេះត្រូវបាន Run នៅលើ SERVER (ServerScriptService)
-- ============================================================================
if RunService:IsServer() then
	print("🚀 [StealEggGUI] កំពុងដំឡើងប្រព័ន្ធនៅលើ Server...")

	local carryEvent = ReplicatedStorage:FindFirstChild("EggCarryStateEvent") or Instance.new("RemoteEvent")
	carryEvent.Name = "EggCarryStateEvent"
	carryEvent.Parent = ReplicatedStorage

	local actionEvent = ReplicatedStorage:FindFirstChild("StealEggActionEvent") or Instance.new("RemoteEvent")
	actionEvent.Name = "StealEggActionEvent"
	actionEvent.Parent = ReplicatedStorage

	local eggsFolder = workspace:FindFirstChild("EggsFolder") or Instance.new("Folder")
	eggsFolder.Name = "EggsFolder"
	eggsFolder.Parent = workspace

	local baseDropZone = workspace:FindFirstChild("BaseDropZone")
	if not baseDropZone then
		baseDropZone = Instance.new("Part")
		baseDropZone.Name = "BaseDropZone"
		baseDropZone.Size = Vector3.new(12, 1, 12)
		baseDropZone.Position = Vector3.new(0, 0.5, 25)
		baseDropZone.Anchored = true
		baseDropZone.BrickColor = BrickColor.new("Lime green")
		baseDropZone.Material = Enum.Material.Neon
		baseDropZone.Parent = workspace
	end

	local carriedEggs = {}

	local function attachEggToPlayer(player, egg, prompt)
		if carriedEggs[player] or egg:FindFirstChild("CarryWeld") then return end
		local character = player.Character
		local rootPart = character and character:FindFirstChild("HumanoidRootPart")
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if not rootPart or not humanoid or humanoid.Health <= 0 then return end

		if prompt then prompt.Enabled = false end
		egg.Anchored = false
		egg.CanCollide = false
		egg.CFrame = rootPart.CFrame * CFrame.new(0, 0, -2.5)

		local weld = Instance.new("WeldConstraint")
		weld.Name = "CarryWeld"
		weld.Part0 = rootPart
		weld.Part1 = egg
		weld.Parent = egg

		carriedEggs[player] = egg
		humanoid.WalkSpeed = math.max(10, humanoid.WalkSpeed - 4)
		carryEvent:FireClient(player, true, egg, egg:GetAttribute("EggName") or "Golden Egg")
	end

	local function spawnEgg(position, eggName, eggValue, color)
		local egg = Instance.new("Part")
		egg.Name = "Egg"
		egg.Shape = Enum.PartType.Ball
		egg.Size = Vector3.new(3, 4, 3)
		egg.Position = position
		egg.Anchored = true
		egg.Material = Enum.Material.SmoothPlastic
		egg.Color = color
		egg:SetAttribute("EggName", eggName)
		egg:SetAttribute("EggValue", eggValue)
		egg.Parent = eggsFolder

		local prompt = Instance.new("ProximityPrompt")
		prompt.ActionText = "Steal Egg"
		prompt.ObjectText = eggName .. " ($" .. eggValue .. ")"
		prompt.HoldDuration = 0.5
		prompt.MaxActivationDistance = 12
		prompt.Parent = egg

		prompt.Triggered:Connect(function(player)
			local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
			if rootPart and (rootPart.Position - egg.Position).Magnitude <= 16 then
				attachEggToPlayer(player, egg, prompt)
			end
		end)
	end

	if #eggsFolder:GetChildren() == 0 then
		spawnEgg(Vector3.new(-15, 2.5, -20), "Common Egg", 50, Color3.fromRGB(130, 200, 255))
		spawnEgg(Vector3.new(0, 2.5, -25), "Golden Dragon Egg", 250, Color3.fromRGB(255, 215, 0))
		spawnEgg(Vector3.new(15, 2.5, -20), "Mythic Void Egg", 1000, Color3.fromRGB(170, 0, 255))
	end

	local function deliverEgg(player)
		local egg = carriedEggs[player]
		if not egg then return end

		local eggName = egg:GetAttribute("EggName") or "Egg"
		local eggValue = egg:GetAttribute("EggValue") or 100
		local eggColor = egg.Color

		carriedEggs[player] = nil
		egg:Destroy()

		local leaderstats = player:FindFirstChild("leaderstats")
		if leaderstats then
			leaderstats.Cash.Value += eggValue
			leaderstats.Eggs.Value += 1
		end

		local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if humanoid then humanoid.WalkSpeed = 16 end

		carryEvent:FireClient(player, false)

		task.delay(4, function()
			spawnEgg(Vector3.new(math.random(-20, 20), 2.5, -22), eggName, eggValue, eggColor)
		end)
	end

	baseDropZone.Touched:Connect(function(hit)
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if player and carriedEggs[player] then
			deliverEgg(player)
		end
	end)

	Players.PlayerAdded:Connect(function(player)
		local leaderstats = Instance.new("Folder", player)
		leaderstats.Name = "leaderstats"

		local cash = Instance.new("IntValue", leaderstats)
		cash.Name = "Cash"
		cash.Value = 0

		local eggs = Instance.new("IntValue", leaderstats)
		eggs.Name = "Eggs"
		eggs.Value = 0
	end)

	actionEvent.OnServerEvent:Connect(function(player, actionType, value)
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local rootPart = character and character:FindFirstChild("HumanoidRootPart")
		if not character or not humanoid or not rootPart then return end

		if actionType == "SetSpeed" then
			humanoid.WalkSpeed = math.clamp(tonumber(value) or 16, 16, 150)
		elseif actionType == "GrabNearestEgg" then
			local closest, minDist = nil, 100
			for _, item in ipairs(eggsFolder:GetChildren()) do
				if item:IsA("BasePart") and not item:FindFirstChild("CarryWeld") then
					local d = (rootPart.Position - item.Position).Magnitude
					if d < minDist then minDist = d closest = item end
				end
			end
			if closest then
				attachEggToPlayer(player, closest, closest:FindFirstChildOfClass("ProximityPrompt"))
			end
		elseif actionType == "TeleportToBase" then
			rootPart.CFrame = baseDropZone.CFrame + Vector3.new(0, 4, 0)
			if carriedEggs[player] then deliverEgg(player) end
		end
	end)

	return
end

-- ============================================================================
-- ផ្នែកទី ២៖ ប្រសិនបើកូដនេះត្រូវបាន Run នៅលើ CLIENT (LocalScript)
-- ============================================================================
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local carryEvent = ReplicatedStorage:WaitForChild("EggCarryStateEvent")
local actionEvent = ReplicatedStorage:WaitForChild("StealEggActionEvent")
local eggsFolder = workspace:WaitForChild("EggsFolder")
local baseDropZone = workspace:WaitForChild("BaseDropZone")

if playerGui:FindFirstChild("StealEggMasterGUI") then
	playerGui.StealEggMasterGUI:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StealEggMasterGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 270, 0, 215)
mainFrame.Position = UDim2.new(0.03, 0, 0.38, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(22, 24, 32)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

local titleBar = Instance.new("TextLabel")
titleBar.Size = UDim2.new(1, 0, 0, 38)
titleBar.BackgroundColor3 = Color3.fromRGB(35, 38, 52)
titleBar.TextColor3 = Color3.fromRGB(85, 255, 127)
titleBar.Font = Enum.Font.GothamBold
titleBar.TextSize = 15
titleBar.Text = "🥚 StealEggGUI (GitHub Sync)"
titleBar.Parent = mainFrame
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)

local function addBtn(text, yPos, color, fn)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0.88, 0, 0, 36)
	b.Position = UDim2.new(0.06, 0, 0, yPos)
	b.BackgroundColor3 = color
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 13
	b.Text = text
	b.Parent = mainFrame
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
	b.MouseButton1Click:Connect(function() fn(b) end)
end

addBtn("🖐️ លួចពងជិតបំផុត (Grab [E])", 50, Color3.fromRGB(45, 120, 220), function()
	actionEvent:FireServer("GrabNearestEgg")
end)

addBtn("🏠 យកពងទៅបន្ទាយ (TP Base)", 96, Color3.fromRGB(40, 170, 95), function()
	actionEvent:FireServer("TeleportToBase")
end)

local fast = false
addBtn("⚡ ល្បឿនរត់៖ ធម្មតា (16)", 142, Color3.fromRGB(160, 90, 220), function(btn)
	fast = not fast
	btn.Text = fast and "⚡ ល្បឿនរត់៖ លឿន (55)" or "⚡ ល្បឿនរត់៖ ធម្មតា (16)"
	actionEvent:FireServer("SetSpeed", fast and 55 or 16)
end)

UserInputService.InputBegan:Connect(function(input, gp)
	if not gp and input.KeyCode == Enum.KeyCode.E then
		actionEvent:FireServer("GrabNearestEgg")
	end
end)
