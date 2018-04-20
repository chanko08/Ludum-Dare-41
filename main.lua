-- Globally defined because these will be used literally everywhere
class = require 'lib.hump.class'
gs = require 'lib.hump.gamestate'
inspect = require 'lib.inspect.inspect'


local GameState = require 'states.game'

function love.load()
    gs.registerEvents()
    gs.switch(GameState)
end
