local PowerUp = class({})

function PowerUp:init(x, y, w, h, powerup, state)
    self.x = x
    self.y = y
    self.w = w
    self.h = h
    self.powerup = powerup
    self.state = state

    local power_up_speed = 250
    self.vx = 0
    self.vy = power_up_speed

    self.is_dead = false
    self.is_powerup = true
end

function PowerUp:add_to_world(world)
    world:add(self, self.x, self.y, self.w, self.h)
end

function PowerUp:draw()
    love.graphics.draw(self.powerup.image, self.powerup.quad, self.x, self.y)
end

function PowerUp:update(world, dt)
    local actualX, actualY, cols, len = world:move(
        self,
        self.x + self.vx*dt,
        self.y + self.vy*dt,
        function(item, other)
            return "cross"
        end
    )
    self.x = actualX
    self.y = actualY
    for i=1,len do
        if cols[i].other.is_paddle then
            self.powerup.action(self, cols[i].other, state)
        end
    end

    return self.is_dead
end

return PowerUp