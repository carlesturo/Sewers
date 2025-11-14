-- From "Sewers" mod -- Author = carlesturo

local Sewers_Data = require "Sewers_Data"
local Sewers_Utils = require "Sewers_Utils"

Sewers_WorldContextMenu = {}

-- ------------------------------------------------------------------------------------------------

-- **************** OPEN MANHOLE COVER ACTION ****************

Sewers_WorldContextMenu.onOpenManholeCover = function(object, playerObj)
    Sewers_Utils.walkAndOpenOrCloseManholeCover(playerObj, object, true)
end

-- ------------------------------------------------------------------------------------------------

-- **************** CLOSE MANHOLE COVER ACTION ****************

Sewers_WorldContextMenu.onCloseManholeCover = function(object, playerObj)
	Sewers_Utils.walkAndOpenOrCloseManholeCover(playerObj, object, false)
end

-- ------------------------------------------------------------------------------------------------

-- **************** SEWERS - WORLD CONTEXT MENU ****************

Sewers_WorldContextMenu.initWorldContextMenu = function(playerNum, context, worldobjects)
    local playerObj = getSpecificPlayer(playerNum)
    if playerObj:getVehicle() then return end
    local cell = getCell()

    local manholeClosed = "street_decoration_01_15"
    local manholeCover = nil
    local sewerHoleSprite = nil
    local clickedSquare = nil

    for _, object in ipairs(worldobjects) do
        if instanceof(object, "IsoObject") and object:getSprite() then
            local name = object:getSprite():getName()
            local square = object:getSquare()
            if not clickedSquare then clickedSquare = square end

            if name == manholeClosed then
                manholeCover = object
            else
                for _, sewer in pairs(Sewers_Data.GroundToSewerHole) do
                    if name == sewer then
                        sewerHoleSprite = object
                        break
                    end
                end
            end

            local aboveSquare = cell:getGridSquare(square:getX(), square:getY(), square:getZ() + 1)
            if aboveSquare then
                for i = 0, aboveSquare:getObjects():size() - 1 do
                    local objAbove = aboveSquare:getObjects():get(i)
                    if objAbove and objAbove:getSprite() then
                        local nameAbove = objAbove:getSprite():getName()
                        if nameAbove == manholeClosed then
                            manholeCover = objAbove
                        else
                            for _, sewer in pairs(Sewers_Data.GroundToSewerHole) do
                                if nameAbove == sewer then
                                    sewerHoleSprite = objAbove
                                    break
                                end
                            end
                        end
                    end
                    if manholeCover or sewerHoleSprite then break end
                end
            end
            if manholeCover or sewerHoleSprite then break end
        end
    end

    if not clickedSquare then return end

    if not sewerHoleSprite then
        for dx = -1, 1 do
            for dy = -1, 1 do
                local sq = cell:getGridSquare(clickedSquare:getX() + dx, clickedSquare:getY() + dy, clickedSquare:getZ())
                if sq then
                    for i = 0, sq:getObjects():size() - 1 do
                        local obj = sq:getObjects():get(i)
                        if obj and obj:getSprite() then
                            local name = obj:getSprite():getName()
                            for _, sewer in pairs(Sewers_Data.GroundToSewerHole) do
                                if name == sewer then
                                    sewerHoleSprite = obj
                                    break
                                end
                            end
                        end
                        if sewerHoleSprite then break end
                    end
                end
                if sewerHoleSprite then break end
            end
            if sewerHoleSprite then break end
        end
    end

    if manholeCover then
        local playerSq = playerObj:getSquare()
        local coverSq = manholeCover:getSquare()
        local isBelow = playerSq:getZ() == coverSq:getZ() - 1

        local option = context:addOption(getText("ContextMenu_OpenManholeCover"), manholeCover, Sewers_WorldContextMenu.onOpenManholeCover, playerObj)
        if not isBelow and not (playerObj:getInventory():containsTypeRecurse("Base.Crowbar") or playerObj:getInventory():containsTypeRecurse("Base.CrowbarForged")) then
            option.notAvailable = true
            local tooltip = ISToolTip:new()
            tooltip:initialise()
            tooltip:setVisible(false)
            tooltip.description = "<RED>" .. getText("ContextMenu_Description_RequiresCrowbar")
            option.toolTip = tooltip
        end
        return
    end

	if sewerHoleSprite then
		local canClose = false

		if playerObj:getInventory():containsTypeRecurse("Base.Mov_ManholeCover") then
			canClose = true
        else
            local sq = sewerHoleSprite:getSquare()
            for dx = -1, 1 do
                for dy = -1, 1 do
					local adjSq = cell:getGridSquare(sq:getX() + dx, sq:getY() + dy, sq:getZ())
					if adjSq then
						for i = 0, adjSq:getObjects():size() - 1 do
							local obj = adjSq:getObjects():get(i)
							if instanceof(obj, "IsoWorldInventoryObject") and obj:getItem() then
								local t = obj:getItem():getFullType()
								if t == "Base.Mov_ManholeCover" then
									canClose = true
									break
								end
							end
						end
					end
					if canClose then break end
                end
                if canClose then break end
            end
        end

		if canClose then
			context:addOption(getText("ContextMenu_CloseManholeCover"), sewerHoleSprite, Sewers_WorldContextMenu.onCloseManholeCover, playerObj)
		end
	end
end

Events.OnFillWorldObjectContextMenu.Add(Sewers_WorldContextMenu.initWorldContextMenu)

-- ------------------------------------------------------------------------------------------------