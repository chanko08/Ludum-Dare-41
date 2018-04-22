return function(powerup, paddle, state)

	for entity, exists in pairs(state.entities) do
		if entity.is_ball then
			entity.vx = entity.vx * 1.05
			entity.vy = entity.vy * 1.05
		end
	end
end