local WeirdBlock = class({})

WeirdBlock.is_block = true
WeirdBlock.name = "WeirdBlock"

function WeirdBlock:init(x, y, w, h)
    self.x = x
    self.y = y
    self.w = w
    self.h = h

    self.is_block = true
    self.is_dead = false
end

function WeirdBlock:add_to_world(world)
    world:add(self, self.x, self.y, self.w, self.h)
end

function WeirdBlock:draw()
    local r, g, b, a = love.graphics.getColor( )
    love.graphics.setColor(1, 1, 0)
    love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
    love.graphics.setColor(r, g, b, a)
end

function WeirdBlock:update(state, world, dt)
    return self.is_dead
end

function WeirdBlock:on_ball_collision(ball)
    self.is_dead = true
end

return WeirdBlock