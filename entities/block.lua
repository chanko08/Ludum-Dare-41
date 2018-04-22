local Block = class({})

function Block:init(x, y, w, h, tile, behavior, power_up, sound, state)
    self.x = x
    self.y = y
    self.w = w
    self.h = h
    self.power_up = power_up
    self.behavior = behavior
    self.sound = sound
    self.state = state
    self.is_dead = false
    self.is_block = true
    self.tile = tile
end


function Block:draw()
    if self.tile then
        love.graphics.draw(self.tile.image, self.tile.quad, self.x, self.y)
    end
end

function Block:update(world, dt)
end

return Block