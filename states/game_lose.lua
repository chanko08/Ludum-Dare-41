local GameState = class({})

function GameState:enter()
    love.mouse.setRelativeMode(false)
end

function GameState:draw()
    love.graphics.print("You lose!", 175, 300)
end

function GameState:mousepressed()
    self.game_started = true
    gs.switch(GameStartState)
end

return GameState