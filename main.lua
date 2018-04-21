-- Globally defined because these will be used literally everywhere
class = require 'lib.hump.class'
gs = require 'lib.hump.gamestate'
vector = require 'lib.hump.vector'
inspect = require 'lib.inspect.inspect'

function math.sign(x)
    if x < 0 then
        return -1
    end

    return 1
end



local DungeonRoomState = require 'states.dungeon_room'

function love.load()
    gs.registerEvents()
    gs.switch(DungeonRoomState, 'dungeon_rooms/dungeon2.lua')
end
