-- getgenv().Configs = {
--     ["Race_cfgs"] = {
--         ["Enable"] = true,
--         ["Race"] = "Human",
--         ["CheckMode"] = "", -- Ability, Tier
--         ["Ability"] = 3,
--         ["Tier"] = 10
--     },
--     ["Item_cfgs"] = {
--         ["Enable"] = false,
--         ["Targets"] = {
--             ["Bone"] = {Enabled = false, Goal = 5},
--             ["Dragon Egg"] = {Enabled = false, Goal = 0},
--             ["Dragon Scale"] = {Enabled = false, Goal = 0},
--             ["Blaze Ember"] = {Enabled = false, Goal = 0},
--             ["Rainbow Haki"] = {Enabled = false},
--             ["DacoDoor"] = {Enabled = false}
--         }
--     }
-- }

-- รอแค่ของที่จำเป็นจริงๆ ที่ต้องใช้ใน Logic หลัก
repeat wait() until game:IsLoaded() and game.Players.LocalPlayer

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
    ["Blaze Ember"] = { {id = 587} },
    ["Rainbow Haki"] = { {id = 285} }, -- สีฮาคิรุ้ง
    ["Dragonheart"] = { {id = 207} }, -- หอก
    ["Dragonstorm"] = { {id = 224} } -- ปืนใหญ่
}

local function checkItem(targetList)
    local InventoryController, ItemReplication = getModules()
    if not InventoryController or not ItemReplication then return 0, 0 end

    local totalCount = 0
    local uniqueMatchCount = 0
    local foundIds = {}
    local _mastery = 0

    for _, item in ipairs(InventoryController:GetTiles()) do
        for _, target in ipairs(targetList) do
            if item.ItemId == target.id then
                local count = ItemReplication.Quantity.readClient(item.ItemId, item.NetworkedUID) or 0
                local mastery = ItemReplication.Mastery.readClient(item.ItemId, item.NetworkedUID) or 0
                _mastery = mastery
                totalCount = totalCount + count
                if not foundIds[target.id] then
                    uniqueMatchCount = uniqueMatchCount + 1
                    foundIds[target.id] = true
                end
            end
        end
    end
    return totalCount, uniqueMatchCount, _mastery, foundIds
end

local function logDesc(types)
    if types == "Belt" then return select(2, checkItem(itemList["Doja Belt"])) end
    if types == "Bone" then return (checkItem(itemList["Bone"])) end
    if types == "Heart" then return (checkItem(itemList["Heart"])) end
    if types == "Egg" then return (checkItem(itemList["Dragon Egg"])) end
    if types == "DragonSc" then return (checkItem(itemList["Dragon Scale"])) end
    if types == "BlazeEm" then return (checkItem(itemList["Blaze Ember"])) end

    if types == "RbHaki" then
        local isHasRbHaki = select(4, checkItem(itemList["Rainbow Haki"]))
        if isHasRbHaki[285] then 
            return "🟢" 
        else
            return "🔴"
        end
    end

    if types == "Dragonheart" then return (select(3, checkItem(itemList["Dragonheart"]))) end -- return mastery
    if types == "Dragonstorm" then return (select(3, checkItem(itemList["Dragonstorm"]))) end -- return mastery

    if types == "DacoDoor" then
        local remote = workspace:WaitForChild("HydraIslandClient"):WaitForChild("RemoteFunction")
        local progressData = remote:InvokeServer("progress")
        if progressData.complete == 2 then
            return "🟢" 
        else
            return "🔴"
        end
    end

    return 0
end

-- ฟังก์ชันเช็คว่า Item ทั้งหมดตรงกับเป้าหมายหรือไม่
local function checkItemTargets()
    local cfg = getgenv().Configs["Item_cfgs"]
    if not cfg or not cfg["Enable"] then return false end
    
    local targets = cfg["Targets"]
    for itemName, config in pairs(targets) do
        if config.Enabled then
            if itemName == "Rainbow Haki" then
                if logDesc("RbHaki") ~= "🟢" then return false end
            elseif itemName == "DacoDoor" then
                if logDesc("DacoDoor") ~= "🟢" then return false end
            else
                local currentCount = logDesc(
                    itemName == "Bone" and "Bone" or
                    itemName == "Dragon Egg" and "Egg" or
                    itemName == "Dragon Scale" and "DragonSc" or
                    itemName == "Blaze Ember" and "BlazeEm" or
                    "Unknown"
                )
                if currentCount < config.Goal then
                    return false
                end
            end
        end
    end
    return true
end

-- Main Loop
spawn(function()
    while wait(3) do

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

                -- Logic การเช็ค Item Targets
                local itemCfg = getgenv().Configs["Item_cfgs"]
                if itemCfg["Enable"] and checkItemTargets() then
                    if _G.Horst_AccountChangeDone then
                        _G.Horst_AccountChangeDone()
                    end
                end

                -- สร้างข้อความ
                local msg = string.format(
                    "🎀 Dojo Belt(%s/8) • 🦴 Bones: %s • 💘 Heart: %s • 🥚 Egg: %s • 🍃 Scale: %s • 🔥 Ember: %s • Race: %s V.%s [%s] • 🗡️ Dragonheart: %s • 🔫 Dragonstorm: %s • ⛩️ Door: %s • 🌈 Haki: %s",
                    logDesc("Belt"), logDesc("Bone"), logDesc("Heart"), logDesc("Egg"), logDesc("DragonSc"), logDesc("BlazeEm"),
                    tostring(raceValue), tostring(raceVersion), tostring(raceTierValue), logDesc("Dragonheart"), logDesc("Dragonstorm"), logDesc("DacoDoor"), logDesc("RbHaki")
                )
                
                _G.Horst_SetDescription(msg)
                -- print(msg)
            end)
        else
            print("Waiting for Character or Function...")
        end
    end
end)