-- From "Sewers" mod -- Author = carlesturo

-- **************** OPEN MANHOLE COVER ****************

local Sewers_Data = require "Sewers_Data"
local Sewers_Utils = require "Sewers_Utils"
require "TimedActions/ISBaseTimedAction"

ISOpenManholeCover = ISBaseTimedAction:derive("ISOpenManholeCover")

local manholeClosed = "street_decoration_01_15"

function ISOpenManholeCover:isValid()
    return self.obj ~= nil
end

function ISOpenManholeCover:start()
    self:setActionAnim("Loot")

    if not self.isBelow then
        self:setAnimVariable("LootPosition", "Low")

        local inv = self.character:getInventory()
        local primaryModel = nil

        local equipped = self.character:getPrimaryHandItem()
        if equipped then
            local t = equipped:getFullType()
            if (t == "Base.Crowbar" or t == "Base.CrowbarForged") and not equipped:isBroken() then
                primaryModel = t
            end
        end

        if not primaryModel then
            local crowbarTypes = { "Base.Crowbar", "Base.CrowbarForged" }
            for _, crowbarType in ipairs(crowbarTypes) do
                local items = inv:getItemsFromType(crowbarType, false)
                if items then
                    for i = 0, items:size() - 1 do
                        local item = items:get(i)
                        if item and not item:isBroken() then
                            primaryModel = item:getFullType()
                            break
                        end
                    end
                end
                if primaryModel then break end
            end
        end

        self:setOverrideHandModels(primaryModel, nil)
    else
        self:setAnimVariable("LootPosition", "High")
        self:setOverrideHandModels(nil, nil)
    end
    self.sound = self.character:getEmitter():playSound("PutItemInBag")
end

function ISOpenManholeCover:stop()
    self.character:getEmitter():stopSound(self.sound)
    ISBaseTimedAction.stop(self)
end

function ISOpenManholeCover:perform()
    local square = self.obj:getSquare()
    if not square then return end

    local spriteName = self.obj:getSprite():getName()
    if spriteName ~= manholeClosed then
        ISBaseTimedAction.perform(self)
        return
    end

    square:transmitRemoveItemFromSquare(self.obj)

	if Sewers_Utils.hasValidSewerBelow(square) then
		Sewers_Utils.replaceGroundWithSewerHole(square)
		Sewers_Utils.removeTopOfLadder(square)
	end

	local cell = getCell()
	local targetZ = square:getZ()
	local squareToDrop = nil

	squareToDrop = cell:getGridSquare(square:getX(), square:getY(), targetZ)

	if squareToDrop then
		local positions = {{x = 0.01, y = 0.99}, {x = 0.99, y = 0.01}, {x = 0.01, y = 0.01}, {x = 0.99, y = 0.99}}
		local pos = positions[ZombRand(#positions) + 1]
		squareToDrop:AddWorldInventoryItem("Base.Mov_ManholeCover", pos.x, pos.y, 0.0)
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

function ISOpenManholeCover:new(character, obj, time, isBelow)
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