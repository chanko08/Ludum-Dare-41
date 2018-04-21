local Ball = class({})
Ball.name = "ball"

function Ball:init(x, y, w, h, vx, vy)
    self.x = x
    self.y = y
    self.w = w
    self.h = h
    

    local ball_start_speed = 250
    local ball_start_vx = ball_start_speed * (2 * math.random() - 1)
    local ball_start_vy = ball_start_speed * math.min(math.random(), 0.25)

    self.vx = vx or ball_start_vx
    self.vy = vy or ball_start_vy

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

    local ball_center_x = self.x + self.w / 2
    local ball_center_y = self.y + self.h / 2
    local r, g, b, a = love.graphics.getColor( )
    love.graphics.setColor(0, 1, 1)
    love.graphics.circle('fill', ball_center_x, ball_center_y, self.w / 4)
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
        if cols[i].other.is_block then
            self:block_collision(cols[i])
        elseif cols[i].other.is_paddle then
            self:paddle_collision(cols[i])
        end
    end

    return self.is_dead
end

function Ball:block_collision(col)
    local normal = col.normal
    local flipped_vel = vector(self.vy, self.vx)
    flipped_vel = flipped_vel:mirrorOn(normal)
    self.vx = flipped_vel.y
    self.vy = flipped_vel.x

    local other = col.other
    print(inspect(other))
    other:behavior(self)

end

function Ball:paddle_collision(col)
    local normal = col.normal
    local paddle = col.other

    if normal.x ~= 0 then
        self:block_collision(col)
        return
    end

    local ball_center_x = self.x + self.w / 2
    local paddle_center_x = paddle.x + paddle.w / 2

    ball_center_x = ball_center_x - paddle_center_x
    local direction_change = math.sign(ball_center_x) * math.min(math.abs(ball_center_x / (paddle.w / 2)))

    local max_direction = 70 * math.pi / 180
    local angle = direction_change * max_direction

    local old_ball_direction = vector(self.vx, self.vy)
    local new_ball_direction = vector(0, -1)
    new_ball_direction:rotateInplace(angle)
    new_ball_direction = new_ball_direction * old_ball_direction:len()
    self.vx = new_ball_direction.x
    self.vy = new_ball_direction.y
end

return Ball