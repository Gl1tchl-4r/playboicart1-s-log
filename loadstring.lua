getgenv().Configs = {
    ["Race_cfgs"] = {
        ["Enable"] = true,
        ["Race"] = "Human",
        ["CheckMode"] = "", -- Ability, Tier
        ["Ability"] = 3,
        ["Tier"] = 10
    },
    ["Item_cfgs"] = {
        ["Enable"] = false,
        ["Targets"] = {
            ["Bone"] = {Enabled = false, Goal = 5},
            ["Dragon Egg"] = {Enabled = false, Goal = 0},
            ["Dragon Scale"] = {Enabled = false, Goal = 0},
            ["Blaze Ember"] = {Enabled = false, Goal = 0},
            ["Rainbow Haki"] = {Enabled = false},
            ["DacoDoor"] = {Enabled = false}
        }
    }
}

loadstring(game:HttpGet('https://raw.githubusercontent.com/Gl1tchl-4r/playboicart1-s-log/refs/heads/main/script.lua'))()