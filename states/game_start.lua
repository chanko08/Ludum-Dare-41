local GameState = class({})

function GameState:init()
end

function GameState:draw()
    love.graphics.print("Welcome to Brick Quest", 175, 300)
end

function GameState:mousepressed()
    self.game_started = true
    gs.switch(DungeonLevelState, 'dungeon_rooms/level1.lua')
end

return GameState