local bump = require 'lib.bump.bump'

local DungeonRoomState = class({})

function DungeonRoomState:enter(previous_state, template)
    love.mouse.setRelativeMode(true)

    self.template = template
    self.game_started = false

    self.entities = self:load_entities(self.template)

    self.world = bump.newWorld()
    for entity, i in pairs(self.entities) do
        entity:add_to_world(self.world)
    end
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

function DungeonRoomState:load_entities(template)
    local Block = require 'entities.block'
    local Paddle = require 'entities.paddle'
    local Ball = require 'entities.ball'


    local kill_block = function(block, ball) block.is_dead = true end
    local kill_ball = function(block, ball) ball.is_dead = true end

    local ok, file, room
    ok, file = pcall(love.filesystem.load, template)
    
    if not ok then
        error('Template for dungeon does not exist: ')
    end

    
    ok, room_template = pcall(file)
    if not ok then
        error('Template failed to compile: ' .. template .. '\n' .. room)
    end





    local room
    for i, layer in ipairs(room_template.layers) do
        if layer.name == 'room' then
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


    local entities = {}
    for i, block in ipairs(block_positions) do
        local block = Block(tile_width * block.x, tile_height * block.y , tile_width, tile_height, kill_block)
        entities[block] = true
    end

    -- load initial paddle into room
    -- assume paddle always starts in the middle of the bottom row of the template
    player_width = tile_width * 10
    player_height = 3 * math.floor(tile_height / 4)
    player_start_x = love.graphics.getWidth() / 2 - math.floor(player_width / 2)
    player_start_y = love.graphics.getHeight( ) - tile_height

    local paddle = Paddle(player_start_x, player_start_y, player_width, player_height)
    entities[paddle] = true


    -- load barriers around the game window
    -- left barrier
    local blk
    blk = Block(-25, 0, 25, love.graphics.getHeight( ))
    entities[blk] = true

    -- right barrier
    blk = Block(love.graphics.getWidth( ), 0, 25, love.graphics.getHeight( ))
    entities[blk] = true

    -- top barrier
    blk = Block(-25, -25, love.graphics.getWidth( )+25, 25)
    entities[blk] = true

    blk = Block(-25, love.graphics.getHeight( ), love.graphics.getWidth( )+25, 25, kill_ball)
    entities[blk] = true


    -- load initial ball into room
    -- assume ball always starts above the paddle
    ball_width = math.floor(tile_width / 2)
    ball_height = math.floor(tile_height / 2)
    ball_start_x = player_start_x + math.floor(player_width / 2) - math.floor(ball_width / 2)
    ball_start_y = player_start_y + ball_height
    ball_start_speed = 100
    ball_start_vx = ball_start_speed * (2 * math.random() - 1)
    ball_start_vy = ball_start_speed * math.floor(math.random() + 0.5)
    local ball = Ball(
        ball_start_x,
        ball_start_y,
        ball_width,
        ball_height,
        ball_start_vx,
        ball_start_vy
    )
    entities[ball] = true


    return entities
end

function DungeonRoomState:test_load_entities(template)

    -- body

    local entities = {}

    local Block = require 'entities.block'
    local block = Block(-25, 0, 25, love.graphics.getHeight( ))
    local block1 = Block(love.graphics.getWidth( ), 0, 25, love.graphics.getHeight( ))
    local block2 = Block(-25, -25, love.graphics.getWidth( )+25, 25)
    local block3 = Block(-25, love.graphics.getHeight( ), love.graphics.getWidth( )+25, 25, function(block, ball)
        ball.is_dead = true
    end)
    entities[block] = true
    entities[block1] = true
    entities[block2] = true
    entities[block3] = true


    local Paddle = require 'entities.paddle'
    local paddle = Paddle(30, love.graphics.getHeight( )-30, 100, 25)
    entities[paddle] = true

    local Ball = require 'entities.ball'
    local ball = Ball(300, 300, 25, 25, 100, -100)
    entities[ball] = true


    local enemy = Block(0, 0, love.graphics.getWidth( ), 25, function(block, ball)
        block.is_dead = true
    end)
    entities[enemy] = true


    return entities
end

return DungeonRoomState