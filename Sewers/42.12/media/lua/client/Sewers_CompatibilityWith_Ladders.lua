-- From "Sewers" mod -- Author = carlesturo

-- **************** SEWERS - COMPATIBILITY WITH - LADDERS ****************

local Sewers_Utils = require("Sewers_Utils")
local Sewers_Data = require("Sewers_Data")

local tickCount = 0
local waitingPlayer = nil

Events.OnPlayerUpdate.Add(function(player)
    if not player or player:isDead() then return end

    if player:getVariableString("ClimbLadder") == "true" and not waitingPlayer then
        waitingPlayer = player
        tickCount = 0
        Events.OnTick.Add(OnTick_RemoveLadder)
    end
end)

function OnTick_RemoveLadder()
    if not waitingPlayer then
        Events.OnTick.Remove(OnTick_RemoveLadder)
        return
    end

    tickCount = tickCount + 1

    if tickCount >= 120 then
        local sq = waitingPlayer:getSquare()
        if sq then
            local above = getSquare(sq:getX(), sq:getY(), sq:getZ() + 1)
            if above then
                local hasHole = false

                local objects = above:getObjects()
                for i = objects:size() - 1, 0, -1 do
                    local obj = objects:get(i)
                    local spr = obj and obj:getSprite()
                    if spr and Sewers_Data.SewerHoleSprites[spr:getName()] then
                        hasHole = true
                        break
                    end
                end

                if hasHole then
                    Sewers_Utils.removeTopOfLadder(above)
                end
            end
        end

        waitingPlayer = nil
        tickCount = 0
        Events.OnTick.Remove(OnTick_RemoveLadder)
    end
end