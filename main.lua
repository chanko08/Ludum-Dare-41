-- Globally defined because these will be used literally everywhere
class = require 'lib.hump.class'
gs = require 'lib.hump.gamestate'
vector = require 'lib.hump.vector'
inspect = require 'lib.inspect.inspect'
bump = require 'lib.bump.bump'

function math.sign(x)
    if x < 0 then
        return -1
    end

    return 1

end

function load_folder(folder)
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

function load_tileset(tileset)
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

function load_tilelayer(layer, global_tileset, map)
    local tilelayer = {}
    for i, global_tile_id in ipairs(layer.data) do
        -- tile coords shifted 1 to be similar to Lua's starting index of 1 on
        -- table arrays
        local tile_x = (i - 1) % layer.width
        local tile_y = math.floor((i - 1) / layer.width)

        local x = (i - 1) % layer.width * map.tilewidth
        local y = math.floor((i - 1) / layer.width) * map.tileheight
        local tile
        if global_tile_id > 0 then
            tile = global_tileset[global_tile_id]
            
            if not tile then
                local err_str
                err_str = 'WARNING: Global id "%s" in layer "%s" does not match any global ids in all tilesets loaded.'
                error(string.format(err_str, global_tile_id, layer.name))
            end
        end

        table.insert(tilelayer, {
            x=x,
            y=y,
            tile_x = tile_x,
            tile_y = tile_y,
            tile_width = map.tilewidth,
            tile_height = map.tileheight,
            has_tile = tile ~= nil,
            tile = tile,
            global_tile_id = global_tile_id,
            layer_name = layer.name
        })
    end

    return tilelayer
end

function load_map(map_file_path)
    local ok, file
    ok, map_file = pcall(love.filesystem.load, map_file_path)
    
    if not ok then
        local err_str
        err_str ='Problem occurred loading map_file_path: %s\n%s'
        error(string.format(err_str, map_file_path, map_file))
    end

    
    ok, map = pcall(map_file)
    if not ok then
        local err_str
        err_str = 'Template failed to compile: %s\n%s'
        error(string.format(err_str, map_file, map))
    end


    --load tilesets in
    local tilesets = {}
    for i, ts in ipairs(map.tilesets) do
        tilesets[ts.name] = load_tileset(ts)
    end

    -- build global tileset array
    local global_tileset = {}
    for tileset_name, tileset in pairs(tilesets) do
        for tile_global_id, tile in pairs(tileset) do
            if global_tileset[tile_global_id] then
                local err_str, err_str1, err_str2, err_str3
                err_str = "Attempted to overwrite tile with another tile in global tileset\n"
                err_str = err_str + 'Old tile: %s\n'
                error(string.format(err_str, inspect(global_tileset[tile_global_id]), inspect(tile)))
            end
            global_tileset[tile_global_id] = tile
        end
    end

    -- load tile layers in
    local tilelayers = {}
    for i, layer in ipairs(map.layers) do
        if layer.type == 'tilelayer' then
            tilelayers[layer.name] = load_tilelayer(layer, global_tileset, map)
        end
    end

    return {
        tilelayers = tilelayers,
        tilesets = tilesets,
        global_tileset = global_tileset,
        width = map.width,
        tile_width = map.tilewidth,
        height = map.height,
        tile_height = map.tileheight
    }
end

function get_tile_by_property(map, property, value)
    for global_id, tile in pairs(global_tileset) do
        if tile.properties and tile.properties.property and tile.properties.property == value then
            return tile
        end
    end
end



DungeonRoomState = require 'states.dungeon_room'
DungeonLevelState = require 'states.dungeon_level_map'
GameStartState = require 'states.game_start'

function love.load()
    gs.registerEvents()
    gs.switch(GameStartState, 'game_start.lua' )
end
--DungeonLevelState, 'dungeon_rooms/level1.lua'