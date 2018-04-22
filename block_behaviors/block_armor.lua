local behavior = {}
behavior.name = 'kill_block'
setmetatable(behavior, {
    __call = function(t, block, ball)
        block.behavior = block.state.BLOCK_BEHAVIORS['kill_block.lua']
    end 
})

return behavior