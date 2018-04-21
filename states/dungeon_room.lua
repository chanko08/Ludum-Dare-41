local bump = require 'lib.bump.bump'

local DungeonRoomState = class({})

function DungeonRoomState:enter(previous_state, template)
    love.mouse.setRelativeMode(true)

    self.template = template
    self.game_started = false

    self.world = bump.newWorld()
    self.entities = {}
    self:load_entity_classes()
    self:load_template(self.template)
end

function DungeonRoomState:mousepressed()
    self.game_started = true
end

function DungeonRoomState:mousemoved(x, y, dx, dy, istouch)
    for entity, i in pairs(self.entities) do
        if entity.is_paddle then
            entity:move(self.world, x, y, dx, dy)
        end
    end
end

function DungeonRoomState:update(dt)
    for entity,i in pairs(self.entities) do
        local entity_is_dead = entity:update(self.world, dt)
        if entity_is_dead then
            self.entities[entity] = nil
            self.world:remove(entity)

            if entity.is_ball then
                print("you lost!")
            end
        end
    end
end

function DungeonRoomState:draw()
    for entity,i in pairs(self.entities) do
        entity:draw(dt)
    end
end

function DungeonRoomState:keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end

function DungeonRoomState:add_entity(entity)
    self.entities[entity] = true
    entity:add_to_world(self.world)
end

function DungeonRoomState:load_entity_classes()
    self.ENTITIES = {}
    for i, file_name in ipairs(love.filesystem.getDirectoryItems('entities')) do
        file_name = 'entities/' .. file_name
        local ok, file, room
        ok, file = pcall(love.filesystem.load, file_name)
        
        if not ok then
            error('Problem occurred loading entity file: ' .. file_name .. '\n' .. file)
        end

        
        ok, entity_class = pcall(file)
        if not ok then
            error('Entity file failed to compile: ' .. file_name .. '\n' .. entity_class)
        end

        print(inspect(entity_class))
        self.ENTITIES[entity_class.name] = entity_class
    end
end

function DungeonRoomState:load_template(template)

    local ok, file, room
    ok, file = pcall(love.filesystem.load, template)
    
    if not ok then
        error('Problem occurred loading template: ' .. template)
    end

    
    ok, room_template = pcall(file)
    if not ok then
        error('Template failed to compile: ' .. template .. '\n' .. room)
    end





    local room
    for i, layer in ipairs(room_template.layers) do
        if layer.name == 'blocks' then
            room = layer
            break
        end
    end

    if not room then
        error('Unable to find "room" layer in template:' .. template)
    end

    local tile_height = room_template.tileheight
    local tile_width = room_template.tilewidth

    local block_ids = {}
    local block_positions = {}
    for i, block_id in ipairs(room.data) do
        if block_id > 0 then
            block_ids[block_id] = true
            local x = (i - 1) % room.width
            local y = math.floor((i - 1) / room.width)
            table.insert(block_positions, {
                id = block_id,
                x = x,
                y = y
            })
        end
    end


    block_entity_classes = {}
    for entity_name,entity_class in pairs(self.ENTITIES) do
        if entity_class.is_block then
            table.insert(block_entity_classes, entity_class)
        end
    end


    for block_id,v in pairs(block_ids) do
        block_ids[block_id] = block_entity_classes[love.math.random(#block_entity_classes)]
    end

    


    local entities = {}
    for i, block_data in ipairs(block_positions) do
        local block = block_ids[block_data.id](tile_width * block_data.x, tile_height * block_data.y , tile_width, tile_height)
        self:add_entity(block)
    end

    -- load initial paddle into room
    -- assume paddle always starts in the middle of the bottom row of the template
    player_width = tile_width * 10
    player_height = 3 * math.floor(tile_height / 4)
    player_start_x = love.graphics.getWidth() / 2 - math.floor(player_width / 2)
    player_start_y = love.graphics.getHeight( ) - tile_height

    local paddle = self.ENTITIES['paddle'](player_start_x, player_start_y, player_width, player_height)
    self:add_entity(paddle)


    -- load barriers around the game window
    -- left barrier
    local blk
    blk = self.ENTITIES['ImmortalBlock'](-25, 0, 25, love.graphics.getHeight( ))
    self:add_entity(blk)

    -- right barrier
    blk = self.ENTITIES['ImmortalBlock'](love.graphics.getWidth( ), 0, 25, love.graphics.getHeight( ))
    self:add_entity(blk)

    -- top barrier
    blk = self.ENTITIES['ImmortalBlock'](-25, -25, love.graphics.getWidth( )+25, 25)
    self:add_entity(blk)

    blk = self.ENTITIES['LoseBlock'](-25, love.graphics.getHeight( ), love.graphics.getWidth( )+25, 25)
    self:add_entity(blk)


    -- load initial ball into room
    -- assume ball always starts above the paddle
    local ball_width = math.floor(tile_width / 2)
    local ball_height = math.floor(tile_height / 2)
    local ball_start_x = player_start_x + math.floor(player_width / 2) - math.floor(ball_width / 2)
    local ball_start_y = player_start_y - ball_height
    

    local ball = self.ENTITIES['ball'](
        ball_start_x,
        ball_start_y,
        ball_width,
        ball_height,
        ball_start_vx,
        ball_start_vy
    )
    self:add_entity(ball)


    return entities
end

return DungeonRoomState