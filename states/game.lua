local GameState = class({})

function GameState:init()
end

function GameState:draw()
    love.graphics.print("Hello World!", 400, 300)
end

return GameState