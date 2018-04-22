return function(powerup, paddle, state)
	for entity, exists in pairs(state.entities) do
		if entity.is_paddle then

            state.world:remove(entity)
            local oldx = entity.x

            entity.x = 0
            entity.w = math.min(love.graphics.getWidth() - 5, entity.w - 10)
            local width_change = entity.w + 10 - entity.w
        
            state.world:add(entity, entity.x, entity.y, entity.w, entity.h)


            local actualX, actualY, cols, len = state.world:move(entity, oldx - width_change / 2, entity.y, function(item, other)
                if other.is_powerup then
                    return 'cross'
                end
                return 'touch'
            end)
            entity.x = actualX
            entity.y = actualY  
		end
	end
end