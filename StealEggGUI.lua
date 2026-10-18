local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local eggsFolder = workspace:WaitForChild("EggsFolder")

-- កំណត់ចម្ងាយ (គិតជា Studs) ដែលអាចរើសពងបាន
local PICKUP_RANGE = 12 

-- ១. បង្កើតពន្លឺ Highlight សម្រាប់ព័ទ្ធជុំវិញពងដែលនៅជិតបំផុត
local rangeHighlight = Instance.new("Highlight")
rangeHighlight.Name = "EggRangeHighlight"
rangeHighlight.FillColor = Color3.fromRGB(85, 255, 127)
rangeHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
rangeHighlight.FillTransparency = 0.65
rangeHighlight.Enabled = false
rangeHighlight.Parent = workspace

-- ២. បង្កើតផ្ទាំង BillboardGui សម្រាប់បង្ហាញអក្សរ និងចម្ងាយពីលើពង
local rangeBillboard = Instance.new("BillboardGui")
rangeBillboard.Name = "RangeIndicatorGui"
rangeBillboard.Size = UDim2.new(0, 220, 0, 55)
rangeBillboard.StudsOffset = Vector3.new(0, 3.5, 0) -- កម្ពស់ពីលើពង
rangeBillboard.AlwaysOnTop = true
rangeBillboard.Enabled = false
rangeBillboard.Parent = localPlayer:WaitForChild("PlayerGui")

local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, 0, 1, 0)
infoLabel.BackgroundColor3 = Color3.fromRGB(20, 25, 30)
infoLabel.BackgroundTransparency = 0.2
infoLabel.TextColor3 = Color3.fromRGB(85, 255, 127)
infoLabel.Font = Enum.Font.GothamBold
infoLabel.TextSize = 15
infoLabel.Text = ""
infoLabel.Parent = rangeBillboard

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = infoLabel

-- ៣. មុខងារស្វែងរកពងដែលនៅជិតអ្នកលេងបំផុតក្នុងរង្វង់ Range
local function findClosestEggInRange(rootPosition)
	local closestEgg = nil
	local shortestDistance = PICKUP_RANGE

	for _, item in ipairs(eggsFolder:GetChildren()) do
		-- ឆែកមើលថាតើជា BasePart ឬ Model ដែលមាន PrimaryPart
		local eggPart = item:IsA("BasePart") and item or (item:IsA("Model") and item.PrimaryPart)
		
		-- មិនចាប់យកពងណាដែលកំពុងជាប់ Weld (មានគេលួចកាន់រួចហើយ) ទេ
		if eggPart and not eggPart:FindFirstChild("CarryWeld") then
			local distance = (rootPosition - eggPart.Position).Magnitude
			if distance <= shortestDistance then
				shortestDistance = distance
				closestEgg = eggPart
			end
		end
	end

	return closestEgg, shortestDistance
end

-- ៤. ឆែកមើលចម្ងាយជាប្រចាំតាមរយៈ RunService.Heartbeat
RunService.Heartbeat:Connect(function()
	local character = localPlayer.Character
	local rootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not rootPart then
		rangeHighlight.Enabled = false
		rangeBillboard.Enabled = false
		return
	end

	local targetEgg, distance = findClosestEggInRange(rootPart.Position)

	if targetEgg then
		-- បើកសញ្ញាប្រាប់នៅលើពងដែលនៅជិតបំផុត
		rangeHighlight.Adornee = targetEgg
		rangeHighlight.Enabled = true

		rangeBillboard.Adornee = targetEgg
		rangeBillboard.Enabled = true
		infoLabel.Text = string.format("🥚 អាចរើសបាន! (%.1f Studs)\n[ចូលជិតដើម្បីលួចពង]", distance)
	else
		-- បិទសញ្ញាវិញនៅពេលដើរចេញផុតពី Range
		rangeHighlight.Adornee = nil
		rangeHighlight.Enabled = false
		rangeBillboard.Adornee = nil
		rangeBillboard.Enabled = false
	end
end)
