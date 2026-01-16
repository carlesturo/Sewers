-- From "Sewers" mod -- Author = carlesturo

local Sewers_Data = {}

Sewers_Data.GroundToSewerHole = {
    ["blends_street_01_0"]  = "sewers_01_0",
    ["blends_street_01_5"]  = "sewers_01_1",
    ["blends_street_01_16"] = "sewers_01_2",
    ["blends_street_01_21"] = "sewers_01_3",
    ["blends_street_01_32"] = "sewers_01_4",
    ["blends_street_01_37"] = "sewers_01_5",
    ["blends_street_01_38"] = "sewers_01_6",
    ["blends_street_01_39"] = "sewers_01_7",
    ["blends_street_01_48"] = "sewers_01_8",
    ["blends_street_01_53"] = "sewers_01_9",
    ["blends_street_01_54"] = "sewers_01_10",
    ["blends_street_01_55"] = "sewers_01_11",
    ["blends_street_01_64"] = "sewers_01_12",
    ["blends_street_01_69"] = "sewers_01_13",
    ["blends_street_01_70"] = "sewers_01_14",
    ["blends_street_01_71"] = "sewers_01_15",
    ["blends_street_01_80"] = "sewers_01_16",
    ["blends_street_01_85"] = "sewers_01_17",
    ["blends_street_01_86"] = "sewers_01_18",
    ["blends_street_01_87"] = "sewers_01_19",
    ["blends_street_01_96"] = "sewers_01_20",
    ["blends_street_01_101"] = "sewers_01_21",
    ["blends_street_01_102"] = "sewers_01_22",
    ["blends_street_01_103"] = "sewers_01_23"
}

Sewers_Data.SewerHoleSprites = {}
for _, sewerName in pairs(Sewers_Data.GroundToSewerHole) do
    Sewers_Data.SewerHoleSprites[sewerName] = true
end

Sewers_Data.LaddersSewer = {
    ["location_sewer_01_32"] = true,
    ["location_sewer_01_33"] = true,
    ["industry_railroad_05_20"] = true,
    ["industry_railroad_05_21"] = true,
    ["industry_railroad_05_36"] = true,
    ["industry_railroad_05_37"] = true
}

return Sewers_Data