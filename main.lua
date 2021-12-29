-- TODO how to allow resizing properly?

push = require 'modules/push'
Class = require 'modules/class'

--game objects
require 'gameObjects/Paddle'
require 'gameObjects/Ball'

require 'Player'

socket = require "socket"
SERVER_IP = "SERVER IP HERE"
SERVER_PORT = 12345
require "UdpHandler"
udpHandler = UdpHandler(socket, SERVER_IP, SERVER_PORT)

--states
require 'gameStates/BaseState'
require 'gameStates/StartState'
require 'gameStates/ServeState'
require 'gameStates/PlayState'
require 'gameStates/EndState'

-- statemanager
require 'StateManager'
stateManager = StateManager {
  ['start'] = function() return StartState() end,
  ['serve'] = function() return ServeState() end,
  ['play'] = function() return PlayState() end,
  ['end'] = function() return EndState() end
}
-- size of our actual window
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- size we're trying to emulate with push
VIRTUAL_WIDTH = 1280
VIRTUAL_HEIGHT = 720

-- just some info to keep track of standard button sizes
BUTTON_WIDTH = 200
BUTTON_HEIGHT = 64

-- colour settings
BACKGROUND_COLOR = {
  r = 40/255,
  g = 45/255,
  b = 52/255
}

INFO_TEXT_COLOR = {
  r = 1,
  g = 1,
  b = 1
}

-- ball is lime green
BALL_COLOR = {
  r = 239/255,
  g = 201/255,
  b = 255/255
}

--player1 is blue
PLAYER1_COLOR = {
  r = 56/255,
  g = 199/255,
  b = 1
}

--player2 is red
PLAYER2_COLOR = {
  r = 1,
  g = 77/255,
  b = 115/255
}


--paddle settings
PADDLE_WIDTH = 10
PADDLE_HEIGHT = 50
PADDLE_X_DISTANCE_FROM_BORDER = 10
PADDLE_SPEED = 400
MAX_PADDLE_SPEED = 200
FRICTION_CONSTANT = 10
PADDLE_FORCE = 4000

--ball settings
--ball settings
BALL_WIDTH = 10
BALL_HEIGHT = 10

--Gamesettings
WINNING_SCORE = 10

--text settings
-- connect button is 214 x 71 pixels large,
--initialize fonts
SMALL_FONT = love.graphics.newFont('resources/fonts/font.ttf', 16)
MEDIUM_FONT = love.graphics.newFont('resources/fonts/font.ttf', 36)
LARGE_FONT = love.graphics.newFont('resources/fonts/font.ttf', 64)
SCORE_FONT = love.graphics.newFont('resources/fonts/font.ttf', 80)

-- text print settings
TEXT_DISTANCE_FROM_TOP_BORDER = 50


function love.load()
    -- basic love settings
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.window.setTitle('Pong')

    sounds = {
        ['paddle_hit'] = love.audio.newSource('resources/sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('resources/sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('resources/sounds/wall_hit.wav', 'static')
    }

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = false
    })

    -- set stateManager to StartState
    stateManager:change("start", {
      udpHandler = udpHandler
    })
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
    -- add to our table of keys pressed this frame
    love.keyboard.keysPressed[key] = true

    if key == 'escape' then
        love.event.quit()
    end
end

function love.keyboard.wasPressed(key)
  return love.keyboard.keysPressed[key]
end

function love.update(dt)
  stateManager:update(dt)

  love.keyboard.keysPressed = {}
end

function love.draw()
    push:apply('start')

    stateManager:render()

    displayFPS()
    -- end our drawing to push
    push:apply('end')
end

function displayFPS()
    -- simple FPS display across all states
    love.graphics.setFont(SMALL_FONT)
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end

function displayScore(world)
    -- score display
    love.graphics.setFont(SCORE_FONT)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(tostring(world.player1.score), VIRTUAL_WIDTH / 2 - 70,
        VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(world.player2.score), VIRTUAL_WIDTH / 2 + 30,
        VIRTUAL_HEIGHT / 3)
end
