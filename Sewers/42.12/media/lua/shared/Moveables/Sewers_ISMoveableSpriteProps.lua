-- From "Sewers" mod -- Author = carlesturo

-- **************** IS VALID - PLACE - MANHOLE COVER ****************

local Sewers_Data = require "Sewers_Data"
local MANHOLE_COVER = "street_decoration_01_15"

local _orig_canPlaceMoveable = ISMoveableSpriteProps.canPlaceMoveable

function ISMoveableSpriteProps:canPlaceMoveable(character, square, item)
    if not self.sprite or self.sprite:getName() ~= MANHOLE_COVER then
        return _orig_canPlaceMoveable(self, character, square, item)
    end

    local objects = square and square:getObjects()
    if objects then
        for i = 0, objects:size() - 1 do
            local obj = objects:get(i)
            local sprite = obj and obj:getSprite()
            if sprite and Sewers_Data.SewerHoleSprites[sprite:getName()] then
                return true
            end
        end
    end

    return _orig_canPlaceMoveable(self, character, square, item)
end