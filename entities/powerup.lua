local PowerUp = class({})

function PowerUp:init(x, y, w, h, powerup, sound, state)
    self.x = x
    self.y = y
    self.w = w
    self.h = h
    self.powerup = powerup
    self.state = state
    self.sound = sound

    local power_up_speed = 250
    self.vx = 0
    self.vy = power_up_speed

    self.is_dead = false
    self.is_powerup = true
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
            if self.sound then
                love.audio.stop(self.sound)
                love.audio.play(self.sound)
            end
            self.powerup.action(self, cols[i].other, self.state)
            self.is_dead = true
        end
    end

    return self.is_dead
end

return PowerUp