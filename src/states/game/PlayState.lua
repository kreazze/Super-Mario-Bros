--[[
    GD50
    Super Mario Bros. Remake

    -- PlayState Class --
]]

PlayState = Class{__includes = BaseState}

function PlayState:init()
    self.camX = 0
    self.camY = 0
    self.level = LevelMaker.generate(100, 10)
    self.tileMap = self.level.tileMap
    self.background = math.random(3)
    self.backgroundX = 0

    self.gravityOn = true
    self.gravityAmount = 6

    self.player = Player({
        y = 0, 
        -- get a safe column to spawn where there is a definite ground
        -- multiply by 16 (tilesize) to get coordinate
        x = self:getPlayerSpawnColumn() * 16,
        width = 16, height = 20,
        texture = 'blue-alien',
        stateMachine = StateMachine {
            ['idle'] = function() return PlayerIdleState(self.player) end,
            ['walking'] = function() return PlayerWalkingState(self.player) end,
            ['jump'] = function() return PlayerJumpState(self.player, self.gravityAmount) end,
            ['falling'] = function() return PlayerFallingState(self.player, self.gravityAmount) end
        },
        map = self.tileMap,
        level = self.level
    })

    self:spawnEnemies()

    self.player:changeState('falling')
end

function PlayState:update(dt)
    Timer.update(dt)

    -- remove any nils from pickups, etc.
    self.level:clear()

    -- update player and level
    self.player:update(dt)
    self.level:update(dt)

    -- constrain player X no matter which state
    if self.player.x <= 0 then
        self.player.x = 0
    elseif self.player.x > TILE_SIZE * self.tileMap.width - self.player.width then
        self.player.x = TILE_SIZE * self.tileMap.width - self.player.width
    end

    self:updateCamera()
end

function PlayState:render()
    love.graphics.push()
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], math.floor(-self.backgroundX), 0)
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], math.floor(-self.backgroundX),
        gTextures['backgrounds']:getHeight() / 3 * 2, 0, 1, -1)
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], math.floor(-self.backgroundX + 256), 0)
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], math.floor(-self.backgroundX + 256),
        gTextures['backgrounds']:getHeight() / 3 * 2, 0, 1, -1)
    
    -- translate the entire view of the scene to emulate a camera
    love.graphics.translate(-math.floor(self.camX), -math.floor(self.camY))
    
    self.level:render()

    self.player:render()
    love.graphics.pop()
    
    -- render score
    love.graphics.setFont(gFonts['small'])
    love.graphics.setColor(0, 0, 0, 255/255)
    love.graphics.print("Score: " .. tostring(self.player.score), 5, 5)
    love.graphics.setColor(255/255, 255/255, 255/255, 255/255)
    love.graphics.print("Score: " .. tostring(self.player.score), 4, 4)

    -- render the key icon or flag icon
    if self.player.hasKey then 
       love.graphics.draw(gTextures['keys-and-locks'], gFrames['keys-and-locks'][1], VIRTUAL_WIDTH - 24, 4)
    elseif  not self.player.level.locked then
        love.graphics.draw(gTextures['flags'], gFrames['flags'][25], VIRTUAL_WIDTH - 24, 4)
    end

    -- render distance to the flag
    love.graphics.setFont(gFonts['small'])
        love.graphics.setColor(0, 0, 0, 255/255)
    love.graphics.printf(tostring(math.ceil(self.player.level.tileMap.width - self.camX/16) - 16) .. " ft.", 
        1, 4, VIRTUAL_WIDTH, 'center')
    love.graphics.setColor(255/255, 255/255, 255/255, 255/255)  
    love.graphics.printf(tostring(math.ceil(self.player.level.tileMap.width - self.camX/16) - 16) .. " ft.", 
        0, 3, VIRTUAL_WIDTH, 'center')
end

function PlayState:updateCamera()
    -- clamp movement of the camera's X between 0 and the map bounds - virtual width,
    -- setting it half the screen to the left of the player so they are in the center
    self.camX = math.max(0,
        math.min(TILE_SIZE * self.tileMap.width - VIRTUAL_WIDTH,
        self.player.x - (VIRTUAL_WIDTH / 2 - 8)))

    -- adjust background X to move a third the rate of the camera for parallax
    self.backgroundX = (self.camX / 3) % 256
end

--[[
    Adds a series of enemies to the level randomly.
]]
function PlayState:spawnEnemies()
    -- spawn snails in the level
    for x = 1, self.tileMap.width do

        -- flag for whether there's ground on this column of the level
        local groundFound = false

        for y = 1, self.tileMap.height do
            if not groundFound then
                if self.tileMap.tiles[y][x].id == TILE_ID_GROUND then
                    groundFound = true

                    -- random chance, 1 in 20
                    if math.random(20) == 1 then
                        
                        -- instantiate snail, declaring in advance so we can pass it into state machine
                        local snail
                        snail = Snail {
                            texture = 'creatures',
                            x = (x - 1) * TILE_SIZE,
                            y = (y - 2) * TILE_SIZE + 2,
                            width = 16,
                            height = 16,
                            stateMachine = StateMachine {
                                ['idle'] = function() return SnailIdleState(self.tileMap, self.player, snail) end,
                                ['moving'] = function() return SnailMovingState(self.tileMap, self.player, snail) end,
                                ['chasing'] = function() return SnailChasingState(self.tileMap, self.player, snail) end
                            }
                        }
                        snail:changeState('idle', {
                            wait = math.random(5)
                        })

                        table.insert(self.level.entities, snail)
                    end
                end
            end
        end
    end
end

-- return the closest column that has a ground , starting from left
function PlayState:getPlayerSpawnColumn()
    local spawnColumn = 0
    for x = 1, self.level.tileMap.width do
        for y = 5, self.level.tileMap.height do
            if self.level.tileMap.tiles[y][x].id == TILE_ID_GROUND then
                spawnColumn = x -1
                return spawnColumn
            end
        end
    end
end

function PlayState:enter(params)
    -- from playstate:init()
    self.camX = 0
    self.camY = 0
    -- adds 10 to width of the game map everytime the game turns into the next level
    self.level = LevelMaker.generate(params.mapWidth +10, 10) 
    self.tileMap = self.level.tileMap
    self.background = math.random(3)
    self.backgroundX = 0

    self.player.map = self.tileMap
    self.player.level = self.level
    self.player.score = params.score
    self.player.x = self:getPlayerSpawnColumn() * 16

    self:spawnEnemies()
    
    self.player:changeState('falling')
end