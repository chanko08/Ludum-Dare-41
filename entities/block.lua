local Block = class({})

function Block:init(x, y, w, h, on_ball_collision)
    self.x = x
    self.y = y
    self.w = w
    self.h = h

    self.is_block = true
    self.is_dead = false
    self.on_ball_collision = on_ball_collision or function(ball) end
end

function Block:add_to_world(world)
    world:add(self, self.x, self.y, self.w, self.h)
end

function Block:draw()
    local r, g, b, a = love.graphics.getColor( )
    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
    love.graphics.setColor(r, g, b, a)
end

function Block:update(world, dt)
    -- body

    return self.is_dead
end

return Block