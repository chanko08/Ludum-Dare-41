local DungeonLevelMapState = class({})

function DungeonLevelMapState:enter(previous_state, dungeon_level_map, continuing)
    love.mouse.setRelativeMode(false)
    
    if continuing and self.on_final_level then
        print "YOU WIN THE WHOLE GAME!"
        return
    end

    if continuing then
        self.old_entities = previous_state.entities
        return
    end

    

    self.dungeon_level_map = dungeon_level_map
    self.game_started = false
    self.on_final_level = false

    self.world = bump.newWorld()
    self.entities = {}
    self.ENTITIES = load_folder('entities')
    local start_dungeon = self:load_dungeon_level_map(self.dungeon_level_map)
    gs.switch(DungeonRoomState, start_dungeon)
    
end

function DungeonLevelMapState:draw()
    for entity, alive in pairs(self.entities) do
        entity:draw()
    end

    local items, len = self.world:getItems()
    local r, g, b, a = love.graphics.getColor()
    love.graphics.setColor(1, 0, 0)
    for i=1,len do
        local item = items[i]
        love.graphics.rectangle('line', item.x, item.y, item.w, item.h)
    end
    love.graphics.setColor(r, g, b, a)

end


function DungeonLevelMapState:update(dt)
    for entity, alive in pairs(self.entities) do
        entity:update(self.world, dt)
    end
end


function DungeonLevelMapState:add_entity(entity)
    self.entities[entity] = true
    self.world:add(entity, entity.x, entity.y, entity.w, entity.h)
end

function DungeonLevelMapState:remove_entity(entity)
    self.entities[entity] = nil
    self.world:remove(entity)
end

function DungeonLevelMapState:load_dungeon_level_map(dungeon_level_map)
    local start_dungeon
    map = load_map(dungeon_level_map)

    --Merge the tile layers and add them to the world/state. 
    --For the dungeon level map, the 'dungeon_room_numbers' layer is the one
    --that should be drawn
    local merged_layer = {}
    local dungeon_room_numbers = map.tilelayers['dungeon_room_numbers']
    local dungeon_room_behaviors = map.tilelayers['dungeon_room_behaviors']
    local dungeon_room_explored = map.tilelayers['dungeon_room_explored']
    local dungeon_room_unexplored = map.tilelayers['dungeon_room_unexplored']
    local dungeon_room_explorable = map.tilelayers['dungeon_room_explorable']

    local map_width = map.tile_width * map.width
    local map_height = map.tile_height * map.height
    
    local blks = {}
    for i, unexplored_tile in ipairs(dungeon_room_unexplored) do
        local x = unexplored_tile.x + (love.graphics.getWidth() - map_width) / 2
        local y = unexplored_tile.y + (love.graphics.getHeight() - map_height) / 2
        local tile_x = unexplored_tile.tile_x
        local tile_y = unexplored_tile.tile_y

        local tile_height = unexplored_tile.tile_height
        local tile_width = unexplored_tile.tile_width

        local explored_tile = dungeon_room_explored[i]
        local behavior_tile = dungeon_room_behaviors[i]
        local dungeon_number = dungeon_room_numbers[i]
        local explorable = dungeon_room_explorable[i]

        local behavior
        if behavior_tile.has_tile then
            behavior = behavior_tile.tile.properties.name
        end

        local dungeon
        if dungeon_number.has_tile then
            dungeon = dungeon_number.tile.properties.name
        end

        local tiles = {}
        tiles.unexplored = unexplored_tile.tile

        if explored_tile.has_tile then
            tiles.explored = explored_tile.tile
        end
        if explorable.has_tile then
            tiles.explorable = explorable.tile
        end
        local blk =self.ENTITIES['map_block.lua'](
            x,
            y,
            tile_width,
            tile_height,
            tile_x,
            tile_y,
            behavior,
            dungeon,
            tiles,
            self
        )
        blk.test = {
            explored_tile = explored_tile,
            behavior_tile = behavior_tile,
            dungeon_number_tile = dungeon_number,
            explorable_tile = explorable,
            unexplored_tile = unexplored_tile
        }

        if blk.behavior == 'start' then
            start_dungeon = blk.dungeon
        end

        table.insert(blks, blk)
    end

    local grid_w = map.width
    local grid_h = map.height
    local in_bounds = function(coord)
        if not (coord.x > 0 and coord.x <= grid_w) then
            return false
        end

        if not (coord.y > 0 and coord.y <= grid_h) then
            return false
        end

        return true
    end
    for i, blk in ipairs(blks) do
        local tile_x = blk.tile_x
        local tile_y = blk.tile_y

        local adj = {}
        local center = {
            x = tile_x,
            y = tile_y,
            i = i
        }
        local up = {
            x = tile_x,
            y = tile_y - 1,
            i = tile_x + (tile_y - 1) * grid_w + 1
        }
        local down = {
            x = tile_x,
            y = tile_y + 1,
            i = tile_x + (tile_y + 1) * grid_w + 1
        }
        local left = {
            x = tile_x - 1,
            y = tile_y,
            i = (tile_x - 1) + tile_y * grid_w + 1
        }
        local right = {
            x = tile_x + 1,
            y = tile_y,
            i = (tile_x + 1) + tile_y * grid_w + 1
        }
        if in_bounds(up) then
            table.insert(adj, blks[up.i])
        end
        if in_bounds(down) then
            table.insert(adj, blks[down.i])
        end
        if in_bounds(left) then
            table.insert(adj, blks[left.i])
        end
        if in_bounds(right) then
            table.insert(adj, blks[right.i])
        end
        blk.adjacent_tiles = adj

        self:add_entity(blk)
    end
    


    return start_dungeon
end

function DungeonLevelMapState:mousepressed(x, y, button)
    local items, len = self.world:queryPoint(x, y)
    if len > 1 then
        print('somehow clicked more than one tile')
        return
    end

    if len < 1 then
        return
    end

    local blk = items[1]
    if blk.tile.properties.name == 'explorable' then
        blk.tile = blk.tiles.explored
        if blk.behavior == 'end' then
            self.on_final_level = true
        end
        gs.switch(DungeonRoomState, blk.dungeon, self.old_entities)
    end
end

function DungeonLevelMapState:keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end

return DungeonLevelMapState
