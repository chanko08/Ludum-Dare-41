return function(block, ball)
    block.state:remove_entity(block)
    if block.power_up then      
        block.state:add_entity(block.power_up)
    end
end