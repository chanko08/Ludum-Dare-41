local behavior = {}
behavior.name = 'kill_ball'
setmetatable(behavior, {
    __call = function(t, block, ball)
        ball.is_dead = true
    end
})

return behavior