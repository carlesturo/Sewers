-- From "Sewers" mod -- Author = carlesturo

-- **************** PICKUP AND PLACE - MANHOLE COVER ****************

local Sewers_Utils = require "Sewers_Utils"
local Sewers_Data = require "Sewers_Data"

local _orig_ISMoveablesAction_complete = ISMoveablesAction.complete

function ISMoveablesAction:complete(...)
    local square = self.square

    if square and self.mode == "pickup" and self.moveProps and self.moveProps.sprite then
        local manholeCoverSprite = self.moveProps.sprite:getName()
        if manholeCoverSprite == "street_decoration_01_15" then
            if Sewers_Utils.hasValidSewerBelow(square) then
                Sewers_Utils.replaceGroundWithSewerHole(square)
            end
        end
    end

    if square and self.mode == "place" and self.moveProps and self.moveProps.sprite then
        local manholeCoverSprite = self.moveProps.sprite:getName()
        if manholeCoverSprite == "street_decoration_01_15" then
            local objects = square:getObjects()
            for i = objects:size() - 1, 0, -1 do
                local obj = objects:get(i)
                local sprite = obj and obj:getSprite()
                local sewerHoleSprite = sprite and sprite:getName()
                if Sewers_Data.SewerHoleSprites[sewerHoleSprite] then
                    local modData = obj:getModData()
                    local groundToRestore = modData and modData.originalGround
                    if groundToRestore then
                        square:transmitRemoveItemFromSquare(obj)
                        local newGround = IsoObject.new(square, groundToRestore, nil, false)
                        square:AddTileObject(newGround)
                        newGround:transmitCompleteItemToServer()
                    end
                    break
                end
            end
        end
    end

	Sewers_Utils.removeTopOfLadder(square)
    return _orig_ISMoveablesAction_complete(self, ...)
end