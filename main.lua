-- Globally defined because these will be used literally everywhere
class = require 'lib.hump.class'
gs = require 'lib.hump.gamestate'
vector = require 'lib.hump.vector'
inspect = require 'lib.inspect.inspect'


local DungeonRoomState = require 'states.dungeon_room'

function love.load()
    gs.registerEvents()
    gs.switch(DungeonRoomState, 'dungeon_rooms/dungeon1.lua')
end
