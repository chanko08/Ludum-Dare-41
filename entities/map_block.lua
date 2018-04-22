local MapBlock = class({})

function MapBlock:init(x, y, w, h, tile_x, tile_y, behavior, dungeon, tiles, state)
    self.x = x
    self.y = y
    self.tile_x = tile_x
    self.tile_y = tile_y
    self.w = w
    self.h = h
    
    --self.state = state
    self.is_dead = false
    self.is_map_block = true
    self.explored = false
    self.behavior = behavior
    self.dungeon = dungeon
    self.tiles = tiles
    self.adjacent_tiles = {}
   

    --print(inspect(self.tiles.explored))
    self.tile = self.tiles.unexplored
    if self.behavior == 'start' then
        self.tile = self.tiles.explored
        self.explored = true
    end
end


function MapBlock:draw()
    love.graphics.draw(self.tile.image, self.tile.quad, self.x, self.y)
end

function MapBlock:update(world, dt)
    --check if adjacent tiles are explored, if they are and this is
    --explorable then change the tile
    for i,t in ipairs(self.adjacent_tiles) do
        if t.tile.properties.name == 'explored' and self.tiles.explorable then
            if self.tile.properties.name ~= 'explored' then
                self.tile = self.tiles.explorable
            end
        end
    end
end

return MapBlock