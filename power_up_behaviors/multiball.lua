return function(powerup, paddle, state)
    local max_balls = 300
    local ball_count = 0
	for entity, exists in pairs(state.entities) do
		if entity.is_ball then
            ball_count = ball_count + 1
		end
	end

    for entity, exists in pairs(state.entities) do
        if ball_count >= max_balls then
            break
        end

        if entity.is_ball then
            local vel = vector(entity.vx, entity.vy)
            local ball_start_vx = vel:len() * (2 * math.random() - 1)
            local ball_start_vy = vel:len() * math.min(math.random(), 0.25)

            local copy_ball = state.ENTITIES['ball.lua'](
                entity.x,
                entity.y,
                entity.w,
                entity.h
            )
            state.entities[copy_ball] = true
            state.world:add(copy_ball, copy_ball.x, copy_ball.y, copy_ball.w, copy_ball.h)

            ball_count = ball_count + 1
        end
    end

    print("my balls: " .. ball_count)
end