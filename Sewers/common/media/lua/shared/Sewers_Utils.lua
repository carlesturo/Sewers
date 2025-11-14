-- From "Sewers" mod -- Author = carlesturo

local Sewers_Data = require "Sewers_Data"

local Sewers_Utils = {}

-- ------------------------------------------------------------------------------------------------

function Sewers_Utils.isModActivated(modSubstring)
    local mods = getActivatedMods()
    for i = 0, mods:size() - 1 do
        local mod = tostring(mods:get(i))
        if mod:find(modSubstring) then
            return true
        end
    end
    return false
end

-- ------------------------------------------------------------------------------------------------

function Sewers_Utils.walkAndFaceManhole(playerObj, manholeObj, isBelow, onComplete)
    if not playerObj or not manholeObj then
        if onComplete then onComplete(false) end
        return
    end

    local cell = getCell()
    local playerSq = playerObj:getSquare()
    local coverSq = manholeObj:getSquare()
    if not playerSq or not coverSq then
        if onComplete then onComplete(false) end
        return
    end

    if isBelow then
        local belowSq = cell:getGridSquare(coverSq:getX(), coverSq:getY(), coverSq:getZ() - 1)
        if not belowSq then
            if onComplete then onComplete(false) end
            return
        end

        if playerSq:getX() == belowSq:getX() and playerSq:getY() == belowSq:getY() then
            playerObj:faceThisObject(manholeObj)
            if onComplete then onComplete(false) end
        else
            local walkAction = ISWalkToTimedAction:new(playerObj, belowSq)
            walkAction:setOnComplete(function()
                playerObj:faceThisObject(manholeObj)
                if onComplete then onComplete(true) end
            end)
            ISTimedActionQueue.add(walkAction)
        end
        return
    end

    local adjacentSq = AdjacentFreeTileFinder.Find(coverSq, playerObj)
    if not adjacentSq then
        if onComplete then onComplete(false) end
        return
    end

    if playerSq:isAdjacentTo(coverSq) then
        playerObj:faceThisObject(manholeObj)
        if onComplete then onComplete(false) end
    else
        local walkAction = ISWalkToTimedAction:new(playerObj, adjacentSq)
        walkAction:setOnComplete(function()
            playerObj:faceThisObject(manholeObj)
            if onComplete then onComplete(true) end
        end)
        ISTimedActionQueue.add(walkAction)
    end
end

-- ------------------------------------------------------------------------------------------------

function Sewers_Utils.walkAndOpenOrCloseManholeCover(playerObj, manholeObj, isOpening)
    if not playerObj or not manholeObj then return end

    local cell = getCell()
    local playerSq = playerObj:getSquare()
    local coverSq = manholeObj:getSquare()
    if not playerSq or not coverSq then return end

    local isBelow = playerSq:getZ() == coverSq:getZ() - 1
    local actionType = isOpening and ISOpenManholeCover or ISCloseManholeCover

	-- --------------------------------------------------
    local function prepareItemsIfNeeded(onReady)
        local inv = playerObj:getInventory()

		-- Open Manhole Cover
        if isOpening then
            if isBelow then
                onReady(false)
                return
            end

			local primary = playerObj:getPrimaryHandItem()
			local primaryType = primary and primary:getFullType() or nil

			if (primaryType == "Base.Crowbar" or primaryType == "Base.CrowbarForged")
				and not primary:isBroken() then
				onReady(false)
				return
			end

			local crowbarTypes = { "Base.Crowbar", "Base.CrowbarForged" }
			local usableCrowbar

			for _, crowbarType in ipairs(crowbarTypes) do
				local items = inv:getItemsFromType(crowbarType, false)
				if items then
					for i = 0, items:size() - 1 do
						local item = items:get(i)
						if item and not item:isBroken() then
							usableCrowbar = item
							break
						end
					end
				end
				if usableCrowbar then break end
			end

			if not usableCrowbar then
				for _, crowbarType in ipairs(crowbarTypes) do
					local items = inv:getAllTypeRecurse(crowbarType)
					if items then
						for i = 0, items:size() - 1 do
							local item = items:get(i)
							if item and not item:isBroken() then
								usableCrowbar = item
								break
							end
						end
					end
					if usableCrowbar then break end
				end
			end

			local container = usableCrowbar:getContainer()
			local needsTransfer = container ~= inv
			local needsEquip = playerObj:getPrimaryHandItem() ~= usableCrowbar

            local function equipCrowbarAndAfterEquip()
                if needsEquip then
                    ISInventoryPaneContextMenu.equipWeapon(usableCrowbar, false, true, playerObj:getPlayerNum())
                end
                Sewers_Utils.walkAndFaceManhole(playerObj, manholeObj, isBelow, onReady)
            end

            if needsTransfer then
                local transfer = ISInventoryTransferAction:new(playerObj, usableCrowbar, container, inv)
                transfer:setOnComplete(equipCrowbarAndAfterEquip)
                ISTimedActionQueue.add(transfer)
            else
                equipCrowbarAndAfterEquip()
            end
            return
        end

		-- Close Manhole Cover
        local foundWorldCover = false
        local square = manholeObj:getSquare()
        if square then
            for dx = -1, 1 do
                for dy = -1, 1 do
                    local adjSq = cell:getGridSquare(square:getX() + dx, square:getY() + dy, square:getZ())
                    if adjSq then
                        for i = 0, adjSq:getObjects():size() - 1 do
                            local obj = adjSq:getObjects():get(i)
                            if instanceof(obj, "IsoWorldInventoryObject") and obj:getItem() then
                                local t = obj:getItem():getType()
                                if t == "Mov_ManholeCover" or t == "street_decoration_01_15" then
                                    foundWorldCover = true
                                    break
                                end
                            end
                        end
                    end
                    if foundWorldCover then break end
                end
                if foundWorldCover then break end
            end
        end

        if foundWorldCover then
            onReady(false)
            return
        end

        local coverItem = inv:getFirstTypeRecurse("Base.Mov_ManholeCover") or inv:getFirstTypeRecurse("Base.street_decoration_01_15")
        if coverItem and coverItem:getContainer() ~= inv then
            local transfer = ISInventoryTransferAction:new(playerObj, coverItem, coverItem:getContainer(), inv)
            transfer:setOnComplete(function()
                Sewers_Utils.walkAndFaceManhole(playerObj, manholeObj, isBelow, function()
                    onReady(false)
                end)
            end)
            ISTimedActionQueue.add(transfer)
        else
            onReady(false)
        end
    end

	-- --------------------------------------------------
	Sewers_Utils.walkAndFaceManhole(playerObj, manholeObj, isBelow, function()
		prepareItemsIfNeeded(function()
			ISTimedActionQueue.add(actionType:new(playerObj, manholeObj, 100, isBelow))
		end)
	end)
end

-- ------------------------------------------------------------------------------------------------

function Sewers_Utils.hasValidSewerBelow(square)
    if not square then return false end

    local belowSquare = getCell():getGridSquare(square:getX(), square:getY(), square:getZ() - 1)
    if not belowSquare or not belowSquare:getFloor() then return false end

    local belowObjects = belowSquare:getObjects()
    if not belowObjects then return false end

    for i = 0, belowObjects:size() - 1 do
        local belowObj = belowObjects:get(i)
        if belowObj and belowObj:getSprite() then
            local n = belowObj:getSprite():getName()
			if n and Sewers_Data.LaddersSewer[n] then
                return true
            end
        end
    end

    return false
end

-- ------------------------------------------------------------------------------------------------

function Sewers_Utils.replaceGroundWithSewerHole(square)
    if not square then return false end

    local objects = square:getObjects()
    for i = objects:size() - 1, 0, -1 do
        local o = objects:get(i)
        if o and o:getSprite() then
            local groundName = o:getSprite():getName()
            local sewerHoleSprite = Sewers_Data.GroundToSewerHole[groundName]
            if sewerHoleSprite then
                square:transmitRemoveItemFromSquare(o)

                local newObj = IsoObject.new(square, sewerHoleSprite, nil, false)
                newObj:getModData().originalGround = groundName
                square:AddTileObject(newObj)
                newObj:transmitCompleteItemToServer()
                return true
            end
        end
    end

    return false
end

-- ------------------------------------------------------------------------------------------------

function Sewers_Utils.removeTopOfLadder(square)
    if not square then return end
    local objs = square:getObjects()
    for i = objs:size() - 1, 0, -1 do
        local obj = objs:get(i)
        if obj then
            local texName = obj.getTextureName and obj:getTextureName()
                or (obj:getSprite() and obj:getSprite():getName())
            if texName == "TopOfLadderW" or texName == "TopOfLadderN" then
                square:transmitRemoveItemFromSquare(obj)
            end
        end
    end
end

-- ------------------------------------------------------------------------------------------------

return Sewers_Utils