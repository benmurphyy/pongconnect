ServeState = Class{__includes = BaseState}

function ServeState:init()
  self.setUpLocations = true
  self.serveMode = false
  self.waitingForServe = true
  -- timer for update from server, if timer is above 1s then send an update prompt to server
  self.updateTimer = 0
end

function ServeState:enter(enterParams)
  self.udpHandler = enterParams.udpHandler
  self.playerNumber = enterParams.playerNumber
  self.world = enterParams.world
  self.ball = self.world.ball
end

function ServeState:update(dt)
  if self.setUpLocations then
    if self.udpHandler:updateWorld(self.world, self.playerNumber) then
      self.udpHandler:sendUpdateConfirmation()
      self.setUpLocations = false
      self.serveMode = true
    else
      -- if udpTimer is more than 1s, then need to request update again from server
      if self.updateTimer >= 1 then
        self.udpHandler:requestUpdate()
        self.updateTimer = 0
      else
        self.updateTimer = self.updateTimer + dt
      end
    end
  elseif self.serveMode then
    --serveMessage: 1 if your serve, 2 if other palyer serve
    local serveMessage = self.udpHandler:receiveServeMessage()
    if serveMessage == 1 then
      self.serving = true
      self.serveMode = false
      self.waitingForServe = true
    elseif serveMessage == 2 then
      self.serving = false
      self.serveMode = false
      self.waitingForServe = true
    end
    -- mode to wait for the servingplayer to serve, if servingplayer is this player, then listen for enter key press,
    -- if key is pressed, send message to server.
    -- for all players, simply wait for the gamestart message from server to transition to playstate
  elseif self.waitingForServe then
    if self.serving and (love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return')) then
      self.udpHandler:sendServeMessage()
    end
    if self.udpHandler:receiveGameStart() then
      stateManager:change("play", {
        world = self.world,
        playerNumber = self.playerNumber,
        udpHandler = self.udpHandler
      })
    end
  end
end

  function ServeState:render()
    love.graphics.clear(BACKGROUND_COLOR.r, BACKGROUND_COLOR.g, BACKGROUND_COLOR.b)
    for key, entity in pairs(self.world) do
      if key == "player1" then
        love.graphics.setColor(PLAYER1_COLOR.r, PLAYER1_COLOR.g, PLAYER1_COLOR.b)
        entity:render()
      elseif key == "player2" then
        love.graphics.setColor(PLAYER2_COLOR.r, PLAYER2_COLOR.g, PLAYER2_COLOR.b)
        entity:render()
      else
        love.graphics.setColor(BALL_COLOR.r, BALL_COLOR.g, BALL_COLOR.b)
        entity:render()
      end
    end

    if self.waitingForServe then
      love.graphics.setFont(MEDIUM_FONT)
      love.graphics.setColor(INFO_TEXT_COLOR.r, INFO_TEXT_COLOR.g, INFO_TEXT_COLOR.b)
      if self.serving then
        love.graphics.printf("Press enter to serve!", 0,
        TEXT_DISTANCE_FROM_TOP_BORDER, VIRTUAL_WIDTH, 'center')
      else
        love.graphics.printf("Waiting for opponent to serve!", 0,
        TEXT_DISTANCE_FROM_TOP_BORDER, VIRTUAL_WIDTH, 'center')
      end
    end

    --render scores
    displayScore(self.world)
end
