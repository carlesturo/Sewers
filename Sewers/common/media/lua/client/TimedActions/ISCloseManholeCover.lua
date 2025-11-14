-- From "Sewers" mod -- Author = carlesturo

-- **************** CLOSE MANHOLE COVER ****************

local Sewers_Utils = require "Sewers_Utils"
require "TimedActions/ISBaseTimedAction"

ISCloseManholeCover = ISBaseTimedAction:derive("ISCloseManholeCover")

function ISCloseManholeCover:isValid()
    return self.obj ~= nil
end

function ISCloseManholeCover:start()
    self:setActionAnim("Loot")
    if self.isBelow then
        self:setAnimVariable("LootPosition", "High")
    else
        self:setAnimVariable("LootPosition", "Low")
    end
    self:setOverrideHandModels(nil, nil)
    self.sound = self.character:getEmitter():playSound("PutItemInBag")
end

function ISCloseManholeCover:stop()
    self.character:getEmitter():stopSound(self.sound)
    ISBaseTimedAction.stop(self)
end

function ISCloseManholeCover:perform()
    local square = self.obj:getSquare()
    local originalGround = self.obj:getModData().originalGround

    if originalGround then
        square:transmitRemoveItemFromSquare(self.obj)

        local newGroundObj = IsoObject.new(square, originalGround, nil, false)
        square:AddTileObject(newGroundObj)
        newGroundObj:transmitCompleteItemToServer()

        local closedCover = IsoObject.new(square, "street_decoration_01_15", nil, false)
        square:AddTileObject(closedCover)
        closedCover:transmitCompleteItemToServer()
    end

	Sewers_Utils.removeTopOfLadder(square)

	local removed = false
	local cell = getCell()

	for dx = -1, 1 do
		for dy = -1, 1 do
			local adjSq = cell:getGridSquare(square:getX() + dx, square:getY() + dy, square:getZ())
			if adjSq then
				for i = 0, adjSq:getObjects():size() - 1 do
					local obj = adjSq:getObjects():get(i)
					if instanceof(obj, "IsoWorldInventoryObject") and obj:getItem() then
						local t = obj:getItem():getFullType()
						if t == "Base.Mov_ManholeCover" then
							adjSq:transmitRemoveItemFromSquare(obj)
							removed = true
							break
						end
					end
				end
			end
			if removed then break end
		end
		if removed then break end
	end

	if not removed then
		local inv = self.character:getInventory()
		local item = inv:getFirstType("Base.Mov_ManholeCover")
		if item then
			inv:Remove(item)
		end
	end

	if getPlayerInventory and getPlayerLoot then
		local invPage = getPlayerInventory(self.character:getPlayerNum())
		local lootPage = getPlayerLoot(self.character:getPlayerNum())
		if invPage then invPage:refreshBackpacks() end
		if lootPage then lootPage:refreshBackpacks() end
	end

    self.character:getEmitter():stopSound(self.sound)
    ISBaseTimedAction.perform(self)
end

function ISCloseManholeCover:new(character, obj, time, isBelow)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character
    o.obj = obj
    o.stopOnWalk = true
    o.stopOnRun = true
    o.maxTime = time
    o.isBelow = isBelow or false
    if o.character:isTimedActionInstant() then o.maxTime = 1 end
    return o
end