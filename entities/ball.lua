local Ball = class({})

function Ball:init(x, y, w, h, vx, vy)
    self.x = x
    self.y = y
    self.w = w
    self.h = h
    self.vx = vx
    self.vy = vy

    self.is_dead = false
    self.is_ball = true
end

function Ball:add_to_world(world)
    world:add(self, self.x, self.y, self.w, self.h)
end

function Ball:draw()
    local r, g, b, a = love.graphics.getColor( )
    love.graphics.setColor(0, 0, 1)
    love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
    love.graphics.setColor(r, g, b, a)
end

function Ball:update(world, dt)
    local actualX, actualY, cols, len = world:move(
        self,
        self.x + self.vx*dt,
        self.y + self.vy*dt,
        function(item, other) return "bounce" end
    )
    self.x = actualX
    self.y = actualY
    for i=1,len do
        local normal = cols[i].normal
        local flipped_vel = vector(self.vy, self.vx)
        flipped_vel = flipped_vel:mirrorOn(normal)
        self.vx = flipped_vel.y
        self.vy = flipped_vel.x

        local other = cols[i].other
        if other.is_block then
            other:on_ball_collision(self)
        end
    end

    return self.is_dead
end

return Ball