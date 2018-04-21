local Paddle = class({})
Paddle.name = "paddle"

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
    local actualX, actualY, cols, len = world:move(self, self.x + dx, self.y, function(item, other)
        if other.is_powerup then
            return 'cross'
        end
        return 'touch'
    end)
    self.x = actualX
    self.y = actualY
end

function Paddle:draw()
    local r, g, b, a = love.graphics.getColor( )
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
    love.graphics.setColor(r, g, b, a)

    local paddle_center_x = self.x + self.w / 2
    local paddle_center_y = self.y + self.h / 2
    local r, g, b, a = love.graphics.getColor( )
    love.graphics.setColor(0, 1, 1)
    love.graphics.circle('fill', paddle_center_x, paddle_center_y, math.min(self.w / 4, self.h / 4))
    love.graphics.setColor(r, g, b, a)
end

function Paddle:update(world, dt)
    return false
end

function Paddle:on_ball_collision(ball)
end

return Paddle