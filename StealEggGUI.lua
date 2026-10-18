-- ==============================================================
-- Foxname Personal Hub Loader (Universal Script)
-- ==============================================================

-- ១. ដាក់តំណភ្ជាប់ (Raw Links) នៃ Script របស់អ្នកនៅទីនេះ
local StealAnEgg_Script = "https://raw.githubusercontent.com/meyneag837-bot/My-Roblox-Scripts/refs/heads/main/StealEggGUI.lua"
-- អ្នកអាចថែម Script ហ្គេមផ្សេងៗទៀតនៅថ្ងៃក្រោយ (ឧ. local BloxFruit_Script = "...")

-- ២. ផ្គូផ្គង GameId ឬ PlaceId ទៅនឹង Script
local scriptsByGame = {
    [10563114921] = StealAnEgg_Script, -- GameId របស់ហ្គេម Steal An Egg
}

local scriptsByPlace = {
    [107778070777162] = StealAnEgg_Script, -- PlaceId របស់ហ្គេម Steal An Egg
}

-- ៣. រង់ចាំរហូតដល់ហ្គេម Load លេខសម្គាល់ពេញលេញ
local gameId = game.GameId
local placeId = game.PlaceId
while gameId == 0 and placeId == 0 do
    task.wait(1)
    gameId = game.GameId
    placeId = game.PlaceId
end

-- ៤. ឆែកមើលថាតើហ្គេមដែលកំពុងលេងមានក្នុងបញ្ជីរបស់អ្នកឬទេ
local scriptUrl = scriptsByGame[gameId] or scriptsByPlace[placeId]

if not scriptUrl then
    -- លោតសារប្រាប់ក្នុង Console បើចូលលេងហ្គេមផ្សេងដែលមិនទាន់មាន Script
    warn("Foxname Hub: មិនទាន់មាន Script សម្រាប់ហ្គេមនេះទេ! (PlaceId: " .. tostring(placeId) .. ")")
    return
end

print("Foxname Hub: ស្គាល់ហ្គេមហើយ កំពុងដំណើរការ Script...")

-- ៥. ប្រព័ន្ធទាញយក និងដំណើរការកូដ (ព្យាយាម ៣ ដងបើអ៊ីនធឺណិតរអាក់រអួល)
for attempt = 1, 3 do
    local success, sourceCode = pcall(game.HttpGet, game, scriptUrl)
    
    if success and type(sourceCode) == "string" and sourceCode ~= "" then
        local loadFunction = loadstring(sourceCode)
        if loadFunction then
            loadFunction() -- បញ្ជាឱ្យផ្ទាំង Script លោតចេញមក
            print("✅ Foxname Hub ដំណើរការជោគជ័យ!")
            return
        end
    end
    
    warn("⚠️ ការទាញយកបរាជ័យលើកទី " .. attempt .. " កំពុងព្យាយាមម្តងទៀត...")
    task.wait(1) -- រង់ចាំ ១ វិនាទីមុននឹងសាកល្បងម្តងទៀត
end

-- បើអ៊ីនធឺណិតដាច់ ឬ Link ខូច វានឹងលោតសារនេះ
warn("❌ មិនអាចទាញយក Script បានទេ! សូមឆែកមើលអ៊ីនធឺណិត ឬតំណភ្ជាប់ GitHub របស់អ្នក។")
