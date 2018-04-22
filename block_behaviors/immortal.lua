local behavior = {}
behavior.name = 'immortal'
setmetatable(behavior, {
    __call = function(t, block, ball) end
})


return behavior