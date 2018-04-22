local DungeonRoomState = class({})

function DungeonRoomState:enter(previous_state, dungeon_room, previous_entities)
    love.mouse.setRelativeMode(true)

    self.dungeon_level = previous_state
    self.dungeon_room = dungeon_room
    self.game_started = false

    self.world = bump.newWorld()
    self.entities = {}
    self.ENTITIES = self:load_folder('entities')
    self.BLOCK_BEHAVIORS = self:load_folder('block_behaviors')
    self.POWER_UP_BEHAVIORS = self:load_folder('power_up_behaviors')
    self:load_dungeon_room(self.dungeon_room, previous_entities)
    print('loaded room!')
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
        if entity.update then
            entity:update(self.world, dt)
        end
        if entity.is_dead then
            self.entities[entity] = nil
            self.world:remove(entity)

            if entity.is_ball then
                --print("you lost!")
            elseif entity.is_block and entity.power_up then
                print("block destroyed and deploying power_up")
                self.entities[entity.power_up] = true
                self.world:add(entity.power_up, entity.power_up.x, entity.power_up.y, entity.power_up.w, entity.power_up.h)
            end
        end
    end

    local win = true
    for entity, i in pairs(self.entities) do
        if entity.is_block and entity.behavior.name == "kill_block" then
            win = false
            break
        end
    end

    if win then
        gs.switch(self.dungeon_level, nil, true)
    end

    local lose = true
    for entity, i in pairs(self.entities) do
        if entity.is_ball then
            lose = false
        end
    end

    if lose then
        gs.switch(GameLoseState)
    end
end

function DungeonRoomState:draw()
    for entity, alive in pairs(self.entities) do
        if entity.draw then
            entity:draw()
        end
    end
end

function DungeonRoomState:keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end

function DungeonRoomState:add_entity(entity)
    self.entities[entity] = true
    self.world:add(entity, entity.x, entity.y, entity.w, entity.h)
end

function DungeonRoomState:remove_entity(entity)
    self.entities[entity] = nil
    self.world:remove(entity)
end


function DungeonRoomState:load_folder(folder)
    folder_items = {}
    for i, file_name in ipairs(love.filesystem.getDirectoryItems(folder)) do
        file_path = folder .. '/' .. file_name
        local ok, file, room
        ok, file = pcall(love.filesystem.load, file_path)
        
        if not ok then
            error('Problem occurred loading entity file: ' .. file_path .. '\n' .. file)
        end

        
        ok, file_code = pcall(file)
        if not ok then
            error('Entity file failed to compile: ' .. file_path .. '\n' .. entity_class)
        end

        folder_items[file_name] = file_code
    end

    return folder_items
end


function DungeonRoomState:load_tileset(tileset)
    -- load the tileset image
    
    local image = love.graphics.newImage('dungeon_rooms/' .. tileset.image)

    local numtilerows = math.floor(tileset.imagewidth / tileset.tilewidth)
    local numtilecols = math.floor(tileset.imageheight / tileset.tileheight)

    local ts = {}
    for row=0,numtilerows-1 do
        for col=0,numtilecols-1 do
            
            local x = row * tileset.tilewidth
            local y = col * tileset.tileheight

            local tile = {}
            tile.quad = love.graphics.newQuad(
                x,
                y,
                tileset.tilewidth,
                tileset.tileheight,
                tileset.imagewidth,
                tileset.imageheight
            )
            tile.image = image
            tile.width = tileset.tilewidth
            tile.height = tileset.tileheight
            tile.local_id  = col * numtilecols + row
            tile.global_id = tile.local_id + tileset.firstgid 
            tile.tileset_name = tileset.name
            
            ts[tile.local_id] = tile
        end
    end

    for i, property in ipairs(tileset.tiles) do
        ts[property.id].properties = property.properties
    end


    local tiles = {}
    for i, tile in pairs(ts) do
        tiles[tile.global_id] = tile
    end

    return tiles
end

function DungeonRoomState:initialize_player(tile_width, tile_height)
        -- load initial paddle into room
        -- assume paddle always starts in the middle of the bottom row of the template
        local player_width = tile_width * 10
        local player_height = 3 * math.floor(tile_height / 4)
        local player_start_x = love.graphics.getWidth() / 2 - math.floor(player_width / 2)
        local player_start_y = love.graphics.getHeight( ) - tile_height
        local player_sound = love.audio.newSource('sounds/paddle_hit.wav', 'static')

        local paddle = self.ENTITIES['paddle.lua'](player_start_x, player_start_y, player_width, player_height, player_sound)
        self:add_entity(paddle)


        -- load initial ball into room
        -- assume ball always starts above the paddle
        local ball_width = math.floor(tile_width / 2)
        local ball_height = math.floor(tile_height / 2)
        local ball_start_x = player_start_x + math.floor(player_width / 2) - math.floor(ball_width / 2)
        local ball_start_y = player_start_y - ball_height
        

        local ball = self.ENTITIES['ball.lua'](
            ball_start_x,
            ball_start_y,
            ball_width,
            ball_height,
            ball_start_vx,
            ball_start_vy
        )
        self:add_entity(ball)
end

function DungeonRoomState:load_dungeon_room(dungeon_room, previous_entities)

    local ok, file, room
    ok, file = pcall(love.filesystem.load, dungeon_room)
    
    if not ok then
        error('Problem occurred loading dungeon_room: ' .. dungeon_room)
    end

    
    ok, room_template = pcall(file)
    if not ok then
        error('Template failed to compile: ' .. dungeon_room .. '\n' .. room_template)
    end


    -- load the two accepted tilesets in
    local block_behavior_tileset
    local power_up_behavior_tileset
    local block_image_tileset
    for i, ts in ipairs(room_template.tilesets) do
        if ts.name == 'block_behaviors' then
            block_behavior_tileset = self:load_tileset(ts)
        elseif ts.name == 'power_up_behaviors' then
            power_up_behavior_tileset = self:load_tileset(ts)
        elseif ts.name == 'block_images' then
            block_image_tileset = self:load_tileset(ts)
        end
    end

    -- load the three accepted layers in
    local blocks
    local power_ups
    local block_behaviors
    for i, layer in ipairs(room_template.layers) do
        if layer.name == 'blocks' then
            blocks = layer
        elseif layer.name == 'power_ups' then
            power_ups = layer
        elseif layer.name == 'block_behaviors' then
            block_behaviors = layer
        end
    end

    if not blocks then
        error('Unable to find "blocks" layer in dungeon room template:' .. template)
    end

    if not power_ups then
        error('Unable to find "power_ups" layer in dungeon room template:' ..  template)
    end

    if not block_behaviors then
        error('Unable to find "block_behaviors" layer in dungeon room template:' ..  template)
    end


    if not block_behavior_tileset then
        error('Unable to find "block_behaviors" tileset in dungeon room template:' .. template)
    end

    if not power_up_behavior_tileset then
        error('Unable to find "power_up_behaviors" tileset in dungeon room template:' .. template)
    end

    if not block_image_tileset then
        error('Unable to find "block_images" tileset in dungeon room template:' .. template)
    end  


    -- add the block image to the block from the block image layer
    local tile_height = room_template.tileheight
    local tile_width = room_template.tilewidth

    local all_sounds = {}
    local block_ids = {}
    local block_positions = {}
    local block_objects = {}
    for i, block_id in ipairs(blocks.data) do
        if block_id > 0 then
            local x = (i - 1) % blocks.width * tile_width
            local y = math.floor((i - 1) / blocks.width) * tile_height
            local tile = block_image_tileset[block_id]
            local behavior = block_behavior_tileset[block_behaviors.data[i]]
            local power_up = power_up_behavior_tileset[power_ups.data[i]]

            if not tile then
                error('WARNING: Block id does not match any block image ids')
            end
            if not behavior then
                --print('WARNING: Block id does not match any block behavior ids')
            end
            if not power_up then
                --print('WARNING: Block id does not match any power up ids')
            end

            local behavior_action
            if behavior and behavior.properties and behavior.properties.name then
                behavior_action = self.BLOCK_BEHAVIORS[behavior.properties.name]
            else
                -- if no behavior given, default to a do-nothing behavior
                behavior_action = self.BLOCK_BEHAVIORS['immortal.lua']
            end

            local sound
            if behavior and behavior.properties and behavior.properties.sound then
                sound = behavior.properties.sound
                if not all_sounds[sound] then
                    all_sounds[sound] = love.audio.newSource(sound, 'static')
                end
                
                sound = all_sounds[sound]
            end

            local power_up_obj
            if power_up and power_up.properties and power_up.properties.name then
                power_up_action = self.POWER_UP_BEHAVIORS[power_up.properties.name]
                power_up.action = power_up_action
                local sound
                if power_up.properties.sound then
                    sound = power_up.properties.sound
                    if not all_sounds[sound] then
                        all_sounds[sound] = love.audio.newSource(sound, 'static')

                    end
                    sound = all_sounds[sound]
                end
                power_up_obj = self.ENTITIES['powerup.lua'](x, y, tile_width, tile_height, power_up, sound, self)
                --print(inspect(power_up_obj))
            end



            
            table.insert(block_objects, self.ENTITIES['block.lua'](
                x,
                y,
                tile_width,
                tile_height,
                tile,
                behavior_action,
                power_up_obj,
                sound,
                self
            ))
        end
    end

    for i, blk in ipairs(block_objects) do
        self:add_entity(blk)
    end

    -- load barriers around the game window
    -- left barrier
    local blk
    blk = self.ENTITIES['block.lua'](
        -25,
        0,
        25,
        love.graphics.getHeight(),
        nil,
        self.BLOCK_BEHAVIORS['immortal.lua'],
        nil,
        self
    )
    self:add_entity(blk)

    -- right barrier
    blk = self.ENTITIES['block.lua'](
        love.graphics.getWidth(),
        0,
        25,
        love.graphics.getHeight(),
        nil,
        self.BLOCK_BEHAVIORS['immortal.lua'],
        nil,
        self
    )
    self:add_entity(blk)

    -- top barrier
    blk = self.ENTITIES['block.lua'](
        -25,
        -25,
        love.graphics.getWidth() + 25,
        25,
        nil,
        self.BLOCK_BEHAVIORS['immortal.lua'],
        nil,
        self
    )
    self:add_entity(blk)

    blk = self.ENTITIES['block.lua'](
        -25,
        love.graphics.getHeight(),
        love.graphics.getWidth(),
        25,
        nil,
        self.BLOCK_BEHAVIORS['kill_ball.lua'],
        nil,
        self
    )
    self:add_entity(blk)

    if not previous_entities then
        self:initialize_player(tile_width, tile_height)
    else
        local player_width = tile_width * 10
        local player_height = 3 * math.floor(tile_height / 4)
        local player_start_x = love.graphics.getWidth() / 2 - math.floor(player_width / 2)
        local player_start_y = love.graphics.getHeight( ) - tile_height
        local ball_width = math.floor(tile_width / 2)
        local ball_height = math.floor(tile_height / 2)
        local ball_start_x = player_start_x + math.floor(player_width / 2) - math.floor(ball_width / 2)
        local ball_start_y = player_start_y - ball_height

        for old_ent, alive in pairs(previous_entities) do
            if old_ent.is_paddle then        
                old_ent.x = player_start_x
                old_ent.y = player_start_y
                self:add_entity(old_ent)
            elseif old_ent.is_ball then
                old_ent.x = ball_start_x
                old_ent.y = ball_start_y
                self:add_entity(old_ent)
            end

        end
    end

    return entities
end

return DungeonRoomState