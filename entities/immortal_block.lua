local ImmortalBlock = class({})

ImmortalBlock.name = "ImmortalBlock"

function ImmortalBlock:init(x, y, w, h)
    self.x = x
    self.y = y
    self.w = w
    self.h = h

    self.is_block = true
    self.is_dead = false
end

function ImmortalBlock:add_to_world(world)
    world:add(self, self.x, self.y, self.w, self.h)
end

function ImmortalBlock:draw()
    local r, g, b, a = love.graphics.getColor( )
    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
    love.graphics.setColor(r, g, b, a)
end

function ImmortalBlock:update(state, world, dt)
    return self.is_dead
end

function ImmortalBlock:on_ball_collision(ball)
end

return ImmortalBlock