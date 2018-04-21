local NormalBlock = class({})

NormalBlock.is_block = true
NormalBlock.name = "NormalBlock"

function NormalBlock:init(x, y, w, h)
    self.x = x
    self.y = y
    self.w = w
    self.h = h

    self.is_block = true
    self.is_dead = false
end

function NormalBlock:add_to_world(world)
    world:add(self, self.x, self.y, self.w, self.h)
end

function NormalBlock:draw()
    local r, g, b, a = love.graphics.getColor( )
    love.graphics.setColor(0, 1, 1)
    love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
    love.graphics.setColor(r, g, b, a)
end

function NormalBlock:update(state, world, dt)
    return self.is_dead
end

function NormalBlock:on_ball_collision(ball)
    self.is_dead = true
end

return NormalBlock