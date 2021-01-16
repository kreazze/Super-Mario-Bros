--[[
    GD50
    Super Mario Bros. Remake

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    -- Dependencies --

    A file to organize all of the global dependencies for our project, as
    well as the assets for our game, rather than pollute our main.lua file.
]]

--
-- libraries
--
Class = require 'lib/class'
push = require 'lib/push'
Timer = require 'lib/knife.timer'

--
-- our own code
--

-- utility
require 'src/constants'
require 'src/StateMachine'
require 'src/Util'

-- game states
require 'src/states/BaseState'
require 'src/states/game/PlayState'
require 'src/states/game/StartState'

-- entity states
require 'src/states/entity/PlayerFallingState'
require 'src/states/entity/PlayerIdleState'
require 'src/states/entity/PlayerJumpState'
require 'src/states/entity/PlayerWalkingState'

require 'src/states/entity/snail/SnailChasingState'
require 'src/states/entity/snail/SnailIdleState'
require 'src/states/entity/snail/SnailMovingState'

-- general
require 'src/Animation'
require 'src/Entity'
require 'src/GameObject'
require 'src/GameLevel'
require 'src/LevelMaker'
require 'src/Player'
require 'src/Snail'
require 'src/Tile'
require 'src/TileMap'


gSounds = {
    ['jump'] = love.audio.newSource('assets/sounds/jump.wav', 'static'),
    ['death'] = love.audio.newSource('assets/sounds/death.wav', 'static'),
    ['music'] = love.audio.newSource('assets/sounds/music.wav', 'static'),
    ['powerup-reveal'] = love.audio.newSource('assets/sounds/powerup-reveal.wav', 'static'),
    ['pickup'] = love.audio.newSource('assets/sounds/pickup.wav', 'static'),
    ['empty-block'] = love.audio.newSource('assets/sounds/empty-block.wav', 'static'),
    ['kill'] = love.audio.newSource('assets/sounds/kill.wav', 'static'),
    ['kill2'] = love.audio.newSource('assets/sounds/kill2.wav', 'static')
}

gTextures = {
    ['tiles'] = love.graphics.newImage('assets/graphics/tiles.png'),
    ['toppers'] = love.graphics.newImage('assets/graphics/tile_tops.png'),
    ['bushes'] = love.graphics.newImage('assets/graphics/bushes_and_cacti.png'),
    ['jump-blocks'] = love.graphics.newImage('assets/graphics/jump_blocks.png'),
    ['gems'] = love.graphics.newImage('assets/graphics/gems.png'),
    ['backgrounds'] = love.graphics.newImage('assets/graphics/backgrounds.png'),
    ['blue-alien'] = love.graphics.newImage('assets/graphics/blue_alien.png'),
    ['creatures'] = love.graphics.newImage('assets/graphics/creatures.png'),
    ['keys-and-locks'] = love.graphics.newImage('assets/graphics/keys_and_locks.png'),
    ['flags'] = love.graphics.newImage('assets/graphics/flags.png'),
    ['post'] = love.graphics.newImage('assets/graphics/flags.png')
}

gFrames = {
    ['tiles'] = GenerateQuads(gTextures['tiles'], TILE_SIZE, TILE_SIZE),
    
    ['toppers'] = GenerateQuads(gTextures['toppers'], TILE_SIZE, TILE_SIZE),
    
    ['bushes'] = GenerateQuads(gTextures['bushes'], 16, 16),
    ['jump-blocks'] = GenerateQuads(gTextures['jump-blocks'], 16, 16),
    ['gems'] = GenerateQuads(gTextures['gems'], 16, 16),
    ['backgrounds'] = GenerateQuads(gTextures['backgrounds'], 256, 128),
    ['blue-alien'] = GenerateQuads(gTextures['blue-alien'], 16, 20),
    ['creatures'] = GenerateQuads(gTextures['creatures'], 16, 16),
    ['keys-and-locks'] = GenerateQuads(gTextures['keys-and-locks'], 16, 16),
    ['flags'] = GenerateQuads(gTextures['flags'], 16, 16),
    ['post'] = GenerateQuads(gTextures['flags'], 16, 48),
}

-- these need to be added after gFrames is initialized because they refer to gFrames from within
gFrames['tilesets'] = GenerateTileSets(gFrames['tiles'], 
    TILE_SETS_WIDE, TILE_SETS_TALL, TILE_SET_WIDTH, TILE_SET_HEIGHT)

gFrames['toppersets'] = GenerateTileSets(gFrames['toppers'], 
    TOPPER_SETS_WIDE, TOPPER_SETS_TALL, TILE_SET_WIDTH, TILE_SET_HEIGHT)

gFonts = {
    ['small'] = love.graphics.newFont('assets/fonts/font.ttf', 8),
    ['medium'] = love.graphics.newFont('assets/fonts/font.ttf', 16),
    ['large'] = love.graphics.newFont('assets/fonts/font.ttf', 32),
    ['title'] = love.graphics.newFont('assets/fonts/ArcadeAlternate.ttf', 32)
}