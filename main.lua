-- Globally defined because these will be used literally everywhere
class = require 'lib.hump.class'
gs = require 'lib.hump.gamestate'
vector = require 'lib.hump.vector'
inspect = require 'lib.inspect.inspect'

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



local DungeonRoomState = require 'states.dungeon_room'

function love.load()
    gs.registerEvents()
    gs.switch(DungeonRoomState, 'dungeon_rooms/dungeon1.lua')
end
