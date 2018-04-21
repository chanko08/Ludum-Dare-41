local bump = require 'lib.bump.bump'

local DungeonRoomState = class({})

function DungeonRoomState:enter(previous_state, template)
    love.mouse.setRelativeMode(true)

    self.template = template
    self.game_started = false

    self.world = bump.newWorld()
    self.entities = {}
    self.ENTITIES = self:load_folder('entities')
    self.BLOCK_BEHAVIORS = self:load_folder('block_behaviors')
    self.POWER_UP_BEHAVIORS = self:load_folder('power_up_behaviors')
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
        if entity.update then
            entity:update(self.world, dt)
        end
        if entity.is_dead then
            self.entities[entity] = nil
            self.world:remove(entity)

            if entity.is_ball then
                print("you lost!")
            end
        end
    end
end

function DungeonRoomState:draw()
    for entity, alive in pairs(self.entities) do
        if entity.tile then
            love.graphics.draw(entity.tile.image, entity.tile.quad, entity.x, entity.y)
        elseif entity.draw then
            entity:draw()
        end
    end

    --[[
    for entity,i in pairs(self.entities) do
        entity:draw(dt)
    end
    ]]
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
        print(inspect(tile))
        tiles[tile.global_id] = tile
    end

    return tiles
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
                print('WARNING: Block id does not match any block behavior ids')
            end
            if not power_up then
                print('WARNING: Block id does not match any power up ids')
            end

            local behavior_action
            if behavior and behavior.properties.name then
                behavior_action = self.BLOCK_BEHAVIORS[behavior.properties.name]
            else
                -- if no behavior given, default to a do-nothing behavior
                behavior_action = function() end
            end
            table.insert(block_objects, {
                index = i,
                block_id = block_id,
                x = x,
                y = y,
                w = tile_width,
                h = tile_height,
                tile = tile,
                behavior = behavior_action,
                power_up = power_up,
                is_block = true
            })
        end
    end

    for i, blk in ipairs(block_objects) do
        self.entities[blk] = true
        self.world:add(blk, blk.x, blk.y, blk.w, blk.h)
    end

    -- load initial paddle into room
    -- assume paddle always starts in the middle of the bottom row of the template
    player_width = tile_width * 10
    player_height = 3 * math.floor(tile_height / 4)
    player_start_x = love.graphics.getWidth() / 2 - math.floor(player_width / 2)
    player_start_y = love.graphics.getHeight( ) - tile_height

    local paddle = self.ENTITIES['paddle.lua'](player_start_x, player_start_y, player_width, player_height)
    self.entities[paddle] = true
    self.world:add(paddle, paddle.x, paddle.y, paddle.w, paddle.h)


    -- load barriers around the game window
    -- left barrier
    local blk
    blk = {
        index = nil,
        block_id = block_id,
        x = -25,
        y = 0,
        w = 25,
        h = love.graphics.getHeight(),
        tile = nil,
        behavior = self.BLOCK_BEHAVIORS['immortal.lua'],
        power_up = nil,
        is_block = true
    }
    self.entities[blk] = true
    self.world:add(blk, blk.x, blk.y, blk.w, blk.h)

    -- right barrier
    blk = {
        index = nil,
        block_id = block_id,
        x = love.graphics.getWidth( ),
        y = 0,
        w = 25,
        h = love.graphics.getHeight( ),
        tile = nil,
        behavior = self.BLOCK_BEHAVIORS['immortal.lua'],
        power_up = nil,
        is_block = true
    }
    self.entities[blk] = true
    self.world:add(blk, blk.x, blk.y, blk.w, blk.h)

    -- top barrier
    blk = {
        index = nil,
        block_id = block_id,
        x = -25,
        y = -25,
        w = love.graphics.getWidth( )+25,
        h = 25,
        tile = nil,
        behavior = self.BLOCK_BEHAVIORS['immortal.lua'],
        power_up = nil,
        is_block = true
    }
    self.entities[blk] = true
    self.world:add(blk, blk.x, blk.y, blk.w, blk.h)

    blk = {
        index = nil,
        block_id = block_id,
        x = -25,
        y = love.graphics.getHeight(),
        w = love.graphics.getWidth() + 25,
        h = 25,
        tile = nil,
        behavior = self.BLOCK_BEHAVIORS['kill_ball.lua'],
        power_up = nil,
        is_block = true
    }
    self.entities[blk] = true
    self.world:add(blk, blk.x, blk.y, blk.w, blk.h)


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
    self.entities[ball] = true
    self.world:add(ball, ball.x, ball.y, ball.w, ball.h)    

    return entities
end

return DungeonRoomState