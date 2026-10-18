-- ទីតាំង៖ ServerScriptService -> Script (StealEggServer)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ==========================================
-- 1. បង្កើត RemoteEvents ដោយស្វ័យប្រវត្តិ
-- ==========================================
local carryEvent = ReplicatedStorage:FindFirstChild("EggCarryStateEvent") or Instance.new("RemoteEvent")
carryEvent.Name = "EggCarryStateEvent"
carryEvent.Parent = ReplicatedStorage

local actionEvent = ReplicatedStorage:FindFirstChild("StealEggActionEvent") or Instance.new("RemoteEvent")
actionEvent.Name = "StealEggActionEvent"
actionEvent.Parent = ReplicatedStorage

-- ==========================================
-- 2. បង្កើត EggsFolder, BaseDropZone និងពងគំរូ
-- ==========================================
local eggsFolder = workspace:FindFirstChild("EggsFolder")
if not eggsFolder then
	eggsFolder = Instance.new("Folder")
	eggsFolder.Name = "EggsFolder"
	eggsFolder.Parent = workspace
end

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

-- តារាងរក្សាទុកពងដែលអ្នកលេងកំពុងកាន់៖ carriedEggs[player] = eggPart
local carriedEggs = {}

-- មុខងារភ្ជាប់ពងទៅនឹងតួអង្គអ្នកលេង
local function attachEggToPlayer(player, egg, prompt)
	if carriedEggs[player] then return end -- កំពុងកាន់ពងរួចហើយ
	if egg:FindFirstChild("CarryWeld") then return end -- មានគេកាន់រួចហើយ

	local character = player.Character
	local rootPart = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not rootPart or not humanoid or humanoid.Health <= 0 then return end

	if prompt then
		prompt.Enabled = false
	end

	egg.Anchored = false
	egg.CanCollide = false
	egg.CFrame = rootPart.CFrame * CFrame.new(0, 0, -2.5)

	local weld = Instance.new("WeldConstraint")
	weld.Name = "CarryWeld"
	weld.Part0 = rootPart
	weld.Part1 = egg
	weld.Parent = egg

	carriedEggs[player] = egg

	-- បន្ថយល្បឿនពេលកាន់ពងធ្ងន់
	humanoid.WalkSpeed = math.max(10, humanoid.WalkSpeed - 4)

	-- ប្រាប់ Client ឱ្យបើក UI, ពន្លឺ Highlight, ខ្សែ Beam និង Animation លើកដៃ
	carryEvent:FireClient(player, true, egg, egg:GetAttribute("EggName") or "Golden Dragon Egg")
end

-- មុខងារបង្កើតពងនៅក្នុងសំបុក
local function spawnEgg(position, eggName, eggValue, color)
	local egg = Instance.new("Part")
	egg.Name = "Egg"
	egg.Shape = Enum.PartType.Ball
	egg.Size = Vector3.new(3, 4, 3)
	egg.Position = position
	egg.Anchored = true
	egg.Material = Enum.Material.SmoothPlastic
	egg.Color = color or Color3.fromRGB(255, 200, 50)
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
		local character = player.Character
		local rootPart = character and character:FindFirstChild("HumanoidRootPart")
		if not rootPart then return end

		-- ឆែកចម្ងាយលើ Server ការពារការលួចពីចម្ងាយខុសប្រក្រតី
		local dist = (rootPart.Position - egg.Position).Magnitude
		if dist <= prompt.MaxActivationDistance + 5 then
			attachEggToPlayer(player, egg, prompt)
		end
	end)
end

-- បង្កើតពងគំរូ ៣ គ្រាប់ប្រសិនបើមិនទាន់មានក្នុង EggsFolder
if #eggsFolder:GetChildren() == 0 then
	spawnEgg(Vector3.new(-15, 2.5, -20), "Common Egg", 50, Color3.fromRGB(130, 200, 255))
	spawnEgg(Vector3.new(0, 2.5, -25), "Golden Dragon Egg", 250, Color3.fromRGB(255, 215, 0))
	spawnEgg(Vector3.new(15, 2.5, -20), "Mythic Void Egg", 1000, Color3.fromRGB(170, 0, 255))
end

-- ==========================================
-- 3. បង្កើតពិន្ទុ Leaderstats សម្រាប់អ្នកលេង
-- ==========================================
Players.PlayerAdded:Connect(function(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = 0
	cash.Parent = leaderstats

	local eggsStolen = Instance.new("IntValue")
	eggsStolen.Name = "Eggs"
	eggsStolen.Value = 0
	eggsStolen.Parent = leaderstats
end)

-- ==========================================
-- 4. ប្រព័ន្ធដាក់ពងនៅបន្ទាយ (BaseDropZone)
-- ==========================================
local function deliverEgg(player)
	local egg = carriedEggs[player]
	if not egg then return end

	local spawnPos = egg.Position
	local eggName = egg:GetAttribute("EggName") or "Golden Egg"
	local eggValue = egg:GetAttribute("EggValue") or 100
	local eggColor = egg.Color

	carriedEggs[player] = nil
	egg:Destroy()

	-- បូកលុយ និងចំនួនពងក្នុង leaderstats
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		leaderstats.Cash.Value += eggValue
		leaderstats.Eggs.Value += 1
	end

	-- កំណត់ល្បឿនអ្នកលេងឱ្យធម្មតាវិញ
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.WalkSpeed = 16
	end

	-- ប្រាប់ Client ឱ្យបិទ UI, Beam និងទម្លាក់ដៃចុះវិញ
	carryEvent:FireClient(player, false)

	-- បង្កើតពងថ្មីឡើងវិញក្រោយរយៈពេល ៥ វិនាទី
	task.delay(5, function()
		spawnEgg(Vector3.new(math.random(-20, 20), 2.5, -22), eggName, eggValue, eggColor)
	end)
end

baseDropZone.Touched:Connect(function(hit)
	local player = Players:GetPlayerFromCharacter(hit.Parent)
	if player and carriedEggs[player] then
		deliverEgg(player)
	end
end)

-- ==========================================
-- 5. ទទួលបញ្ជាពីផ្ទាំង StealEggGUI (Client -> Server)
-- ==========================================
actionEvent.OnServerEvent:Connect(function(player, actionType, value)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local rootPart = character and character:FindFirstChild("HumanoidRootPart")
	if not character or not humanoid or not rootPart then return end

	if actionType == "SetSpeed" then
		humanoid.WalkSpeed = math.clamp(tonumber(value) or 16, 16, 150)

	elseif actionType == "GrabNearestEgg" then
		-- ស្វែងរកពងដែលនៅជិតបំផុត ហើយចាប់យកភ្លាមៗ
		local closestEgg = nil
		local shortestDist = 100
		for _, item in ipairs(eggsFolder:GetChildren()) do
			if item:IsA("BasePart") and not item:FindFirstChild("CarryWeld") then
				local dist = (rootPart.Position - item.Position).Magnitude
				if dist < shortestDist then
					shortestDist = dist
					closestEgg = item
				end
			end
		end
		if closestEgg then
			local prompt = closestEgg:FindFirstChildOfClass("ProximityPrompt")
			attachEggToPlayer(player, closestEgg, prompt)
		end

	elseif actionType == "TeleportToBase" then
		-- បញ្ជូនអ្នកលេងមកកាន់បន្ទាយភ្លាមៗ
		rootPart.CFrame = baseDropZone.CFrame + Vector3.new(0, 4, 0)
		if carriedEggs[player] then
			deliverEgg(player)
		end
	end
end)
