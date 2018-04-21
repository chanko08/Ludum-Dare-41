local Paddle = class({})

function Paddle:init(x, y, w, h)
    self.x = x
    self.y = y
    self.w = w
    self.h = h

    self.is_paddle = true
end

function Paddle:add_to_world(world)
    world:add(self, self.x, self.y, self.w, self.h)
end

function Paddle:move(world, x, y, dx, dy)
    local actualX, actualY, cols, len = world:move(self, self.x + dx, self.y)
    self.x = actualX
    self.y = actualY
end

function Paddle:draw()
    local r, g, b, a = love.graphics.getColor( )
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
    love.graphics.setColor(r, g, b, a)
end

function Paddle:update(world, dt)
    return false
end

return Paddle