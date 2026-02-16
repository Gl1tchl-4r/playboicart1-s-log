-- getgenv().Configs = {
--     ["Race_cfgs"] = {
--         ["Enable"] = true,
--         ["Race"] = "Human",
--         ["CheckMode"] = "Ability", -- Ability, Tier
--         ["Ability"] = 3,
--         ["Tier"] = 10
--     }
-- }

-- รอแค่ของที่จำเป็นจริงๆ ที่ต้องใช้ใน Logic หลัก
repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer

local Player = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ฟังก์ชันดึง Module แบบปลอดภัย
local function getModules()
    local success, inv = pcall(function() return require(ReplicatedStorage.Controllers.UI.Inventory) end)
    local success2, rep = pcall(function() return require(ReplicatedStorage.Util.ItemReplication) end)
    return success and inv, success2 and rep
end

local itemList = {
    ["Doja Belt"] = { {id = 209}, {id = 210}, {id = 211}, {id = 212}, {id = 213}, {id = 214}, {id = 215}, {id = 216} },
    ["Bone"] = { {id = 585} },
    ["Heart"] = { {id = 570} },
    ["Dragon Egg"] = { {id = 565} },
    ["Dragon Scale"] = { {id = 584} },
    ["Blaze Ember"] = { {id = 587} }
}

local function checkItem(targetList)
    local InventoryController, ItemReplication = getModules()
    if not InventoryController or not ItemReplication then return 0, 0 end

    local totalCount = 0
    local uniqueMatchCount = 0
    local foundIds = {}

    for _, item in ipairs(InventoryController:GetTiles()) do
        for _, target in ipairs(targetList) do
            if item.ItemId == target.id then
                local count = ItemReplication.Quantity.readClient(item.ItemId, item.NetworkedUID) or 0
                totalCount = totalCount + count
                if not foundIds[target.id] then
                    uniqueMatchCount = uniqueMatchCount + 1
                    foundIds[target.id] = true
                end
            end
        end
    end
    return totalCount, uniqueMatchCount
end

local function logDesc(types)
    if types == "Belt" then return select(2, checkItem(itemList["Doja Belt"])) end
    if types == "Bone" then return (checkItem(itemList["Bone"])) end
    if types == "Heart" then return (checkItem(itemList["Heart"])) end
    if types == "Egg" then return (checkItem(itemList["Dragon Egg"])) end
    if types == "DragonSc" then return (checkItem(itemList["Dragon Scale"])) end
    if types == "BlazeEm" then return (checkItem(itemList["Blaze Ember"])) end
    return 0
end

-- Main Loop
spawn(function()
    while task.wait(3) do
        -- เช็คเงื่อนไขความพร้อมข้างใน loop แทนการหยุดสคริปต์
        if Player.Character and _G.Horst_SetDescription then
            pcall(function()
                local data = Player:WaitForChild("Data", 5)
                local raceObj = data:WaitForChild("Race", 5)
                local raceTierObj = raceObj:WaitForChild("C", 5)
                
                local raceValue = raceObj.Value
                local raceTierValue = raceTierObj.Value
                local raceVersion = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer("getRaceLevel")

                -- Logic การเช็ค Race
                local cfg = getgenv().Configs["Race_cfgs"]
                if cfg["Enable"] then
                    local isMatch = false
                    if cfg["CheckMode"] == "Ability" then
                        if raceValue == cfg["Race"] and raceVersion == cfg["Ability"] then isMatch = true end
                    elseif cfg["CheckMode"] == "Tier" then
                        if raceValue == cfg["Race"] and raceTierValue == cfg["Tier"] then isMatch = true end
                    end

                    if isMatch and _G.Horst_AccountChangeDone then
                        _G.Horst_AccountChangeDone()
                    end
                end

                -- สร้างข้อความ
                local msg = string.format(
                    "🎀 Dojo Belt(%s/8) • 🦴 Bones: %s • 💘 Heart: %s • 🥚 Egg: %s • 🍃 Scale: %s • 🔥 Ember: %s • Race: %s V.%s [%s]",
                    logDesc("Belt"), logDesc("Bone"), logDesc("Heart"), logDesc("Egg"), logDesc("DragonSc"), logDesc("BlazeEm"),
                    tostring(raceValue), tostring(raceVersion), tostring(raceTierValue)
                )
                
                _G.Horst_SetDescription(msg)
                print("Updated: " .. msg)
            end)
        else
            print("Waiting for Character or Function...")
        end
    end
end)