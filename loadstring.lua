getgenv().Configs = {
    ["Race_cfgs"] = {
        ["Enable"] = true,
        ["Race"] = "Human",
        ["CheckMode"] = "Ability", -- Ability, Tier
        ["Ability"] = 3,
        ["Tier"] = 10
    },
    ["Item_cfgs"] = {
        ["Enable"] = true,
        ["Targets"] = {
            ["Bone"] = {Enabled = true, Goal = 5},
            ["Dragon Egg"] = {Enabled = true, Goal = 0},
            ["Dragon Scale"] = {Enabled = true, Goal = 0},
            ["Blaze Ember"] = {Enabled = true, Goal = 0}
        }
    }
}

loadstring(game:HttpGet('https://raw.githubusercontent.com/Gl1tchl-4r/playboicart1-s-log/refs/heads/main/script.lua'))()