--[[
potential TODO: ready response confirmation, similar to connect, to ensure ready got to the server
]]

require "uiObjects/Button"
StartState = Class{__includes = BaseState}

local connectionStates = {
  ["waiting for connection"] = "Press Connect!",
  ["after pressed connect"] = "Waiting for Connection...",
  ["connection success"] = "All players connected,\nPress Ready!",
  ["waiting for other player to connect"] = "Connected Successfully,\nWaiting for other player to connect!",
  ["connection failure"] = "Connection Failed, Try Again",
  ["pressed ready"] = "Waiting for other player to press ready"
}

-- local timer for connection timeout
local timer


function StartState:init()
  -- modes for the start screen, starting with connection first
  self.currentConnectionState = connectionStates["waiting for connection"]
  self.connectMode = true
  self.readymode = false
  -- boolean representing whether trying to connect to server currently- for use in update
  self.tryingToConnect = false
  connectButtonImage = love.graphics.newImage("resources/images/buttons/connect/unpressed.png")
  connectButtonPressedImage = love.graphics.newImage("resources/images/buttons/connect/pressed.png")
  readyButtonImage = love.graphics.newImage("resources/images/buttons/ready/unpressed.png")
  readyButtonPressedImage = love.graphics.newImage("resources/images/buttons/ready/pressed.png")
  self.connectButton = Button {
    x = VIRTUAL_WIDTH / 2 - BUTTON_WIDTH / 2,
    y = VIRTUAL_HEIGHT / 3 * 2,
    image = connectButtonImage,
    pressedImage = connectButtonPressedImage,
    oneTimeUse = true,
  }
  self.readyButton = Button {
    x = VIRTUAL_WIDTH / 2 - BUTTON_WIDTH / 2,
    y = VIRTUAL_HEIGHT / 3 * 2,
    image = readyButtonImage,
    pressedImage = readyButtonPressedImage,
    oneTimeUse = true,
  }
end

function StartState:connectButtonAction()
  self.udpHandler:connectToServer()
  self.currentConnectionState = connectionStates["after pressed connect"]
  timer = self.udpHandler.socket.gettime()
  self.tryingToConnect = true
end

function StartState:readyButtonAction()
  self.udpHandler:sendToServer("ready")
  self.currentConnectionState = connectionStates["pressed ready"]
  self.readyMode = false
end

--enterParams
--index 1 - udpHandler
function StartState:enter(enterParams)
  self.udpHandler = enterParams.udpHandler
end

function StartState:update(dt)
  -- start with connectMode first, set up connection to server
  if self.connectMode then
    local connectButtonClicked = self.connectButton:update(dt)
    if connectButtonClicked then
      self:connectButtonAction()
      timer = 0
    elseif self.tryingToConnect then
      if self.udpHandler:connectedToServer() then
        self.currentConnectionState = connectionStates["waiting for other player to connect"]
        self.tryingToConnect = false
      elseif timer > 1 then
        self.connectButton:unlockButton()
        self.currentConnectionState = connectionStates["connection failure"]
      else
        timer = timer + dt
      end
    else -- this runs when waiting for other player to connect, after already connecting successfully
      if self.udpHandler:otherPlayerIsConnected() then
        self.currentConnectionState = connectionStates["connection success"]
        self.readyMode = true
        self.connectMode = false
      end
    end
  elseif self.readyMode then
    if self.readyButton:update(dt) then
        self:readyButtonAction()
    end
  -- this is only reached if both conenct and ready modes have been passed, time to transition
  -- to next state once other player has pressed ready
  else
    -- set player number based on response of server when it confirms all players ready
    local playerNumber = self.udpHandler:otherPlayerIsReady()
    if playerNumber then
      --create all the game objects to enter the serve state, put into world table
      local ball = Ball(0, 0)
      local player1 = Player(PADDLE_X_DISTANCE_FROM_BORDER, VIRTUAL_HEIGHT / 2 - PADDLE_HEIGHT / 2, PADDLE_WIDTH, PADDLE_HEIGHT)
      local player2 = Player(VIRTUAL_WIDTH - PADDLE_X_DISTANCE_FROM_BORDER - PADDLE_WIDTH, VIRTUAL_HEIGHT / 2 - PADDLE_HEIGHT / 2, PADDLE_WIDTH, PADDLE_HEIGHT)
      local world = {
        player1 = player1,
        player2 = player2,
        ball = ball
      }
      stateManager:change("serve", {
        udpHandler = self.udpHandler,
        playerNumber = playerNumber,
        world = world
      })
    end
  end
end

function StartState:render()
  love.graphics.clear(BACKGROUND_COLOR.r, BACKGROUND_COLOR.g, BACKGROUND_COLOR.b)
  if self.connectMode then
    self.connectButton:render()
  elseif self.readyMode then
    self.readyButton:render()
  end
  love.graphics.setFont(LARGE_FONT)
  love.graphics.setColor(INFO_TEXT_COLOR.r, INFO_TEXT_COLOR.g, INFO_TEXT_COLOR.b)
  love.graphics.printf(self.currentConnectionState, 0, TEXT_DISTANCE_FROM_TOP_BORDER, VIRTUAL_WIDTH, "center")
end
