-- From "Sewers" mod -- Author = carlesturo

-- **************** SEWERS - ON LOADED TILE DEFINITIONS - COMPATIBILITY WITH - MDO ****************

-- First activate MoreDamagedObjects, then Sewers.

local Sewers_Utils = require("Sewers_Utils")

Events.OnLoadedTileDefinitions.Add(function(manager)
    if not Sewers_Utils.isModActivated("MoreDamagedObjects") then
        return
    end

    local damagedMap = {
        ["street_decoration_01_57"] = "ct_more_damaged_objects_01_1",
        ["street_decoration_01_58"] = "ct_more_damaged_objects_01_2",
        ["street_decoration_01_59"] = "ct_more_damaged_objects_01_3",
        ["street_decoration_01_60"] = "ct_more_damaged_objects_01_4",
        ["street_decoration_01_61"] = "ct_more_damaged_objects_01_5",
        ["street_decoration_01_62"] = "ct_more_damaged_objects_01_6",
        ["street_decoration_01_65"] = "ct_more_damaged_objects_01_9",
        ["street_decoration_01_66"] = "ct_more_damaged_objects_01_10",
        ["street_decoration_01_67"] = "ct_more_damaged_objects_01_11",
        ["street_decoration_01_68"] = "ct_more_damaged_objects_01_12",
        ["street_decoration_01_69"] = "ct_more_damaged_objects_01_13",
        ["street_decoration_01_70"] = "ct_more_damaged_objects_01_14",
    }

    for sprite, damagedSprite in pairs(damagedMap) do
        local props = manager:getSprite(sprite):getProperties()
        props:set("HitByCar", "")
        props:set("MinimumCarSpeedDmg", "5")
        props:set("DamagedSprite", damagedSprite)
        props:CreateKeySet()
    end

	local props = manager:getSprite("street_decoration_01_12"):getProperties()
	props:set("HitByCar", "")
	props:set("StopCar", "")
	props:set("MinimumCarSpeedDmg", "30")
	props:set("DamagedSprite", "ct_more_damaged_objects_06_44")
	props:CreateKeySet()
end)