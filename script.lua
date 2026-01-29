repeat task.wait(0.1) until game:IsLoaded() and _G.Horst_SetDescription

local itemList = {
    ["Doja Belt"] = {
        {name = "Dojo Belt (Black)", id = 209},
        {name = "Dojo Belt (Red)", id = 210},
        {name = "Dojo Belt (Blue)", id = 211},
        {name = "Dojo Belt (Green)", id = 212},
        {name = "Dojo Belt (Orange)", id = 213},
        {name = "Dojo Belt (Yellow)", id = 214},
        {name = "Dojo Belt (White)", id = 215},
        {name = "Dojo Belt (Purple)", id = 216}
    },
    ["Bone"] = {
        {name = "Dinosaur Bones", id = 585}
    },
    ["Heart"] =  {
        {name = "Leviathan Heart", id = 570}
    },
    ["Dragon Egg"] =  {
        {name = "Dragon Egg", id = 565}
    }
}

local InventoryController = require(game:GetService("ReplicatedStorage").Controllers.UI.Inventory)
local ItemReplication = require(game:GetService("ReplicatedStorage").Util.ItemReplication)

local function checkItem(itemList_)

    local sum = {}
    local count_ = 0

    for _, item in ipairs(InventoryController:GetTiles()) do
        local itemId = item.ItemId
        local uid = item.NetworkedUID
        local count = ItemReplication.Quantity.readClient(itemId, uid) or 0

        for _, target in ipairs(itemList_) do
            if itemId == target.id then
                count_ = count
                table.insert(sum, target.name)
            end
        end
    end

    return count_, #sum

end

local function logDesc(types)
    local count, sum

    if types == "Belt" then
        count, sum = checkItem(itemList["Doja Belt"])
        return sum
    elseif types == "Bone" then
        count = checkItem(itemList["Bone"])
        return  count
    elseif types == "Heart" then
        count = checkItem(itemList["Heart"])
        return  count
    elseif types == "Egg" then
        count = checkItem(itemList["Dragon Egg"])
        return  count
    end

end

while task.wait(3) do
    pcall(function()
        local race = game:GetService("Players").LocalPlayer.Data.Race.Value
        local messages = "🎀 Dojo Belt(" .. logDesc("Belt") .. "/8)" .. " • 🦴 Bones: " .. logDesc("Bone") .. " • 💘 Heart: " .. logDesc("Heart") .. " • 🥚 Dragon Egg: " .. logDesc("Egg") .. " • Race: " .. race

        _G.Horst_SetDescription(messages)

    end)
end
