PlayState = Class{__includes = BaseState}

function PlayState:init()
  --timer for measuring time between update requests to the server
  self.updateTimer = 0
end

function PlayState:enter(enterParams)
  self.world = enterParams.world
  self.player1 = self.world.player1
  self.player2 = self.world.player2
  self.ball = self.world.ball
  self.playerNumber = enterParams.playerNumber
  if self.playerNumber == 1 then
    self.thisPlayer = self.player1
  elseif self.playerNumber == 2 then
    self.thisPlayer = self.player2
  end
  self.udpHandler = enterParams.udpHandler
end

function PlayState:update(dt)
  if love.keyboard.isDown('up') then
    self.thisPlayer.paddle.force = -PADDLE_FORCE
  elseif love.keyboard.isDown('down') then
    self.thisPlayer.paddle.force = PADDLE_FORCE
  else
    self.thisPlayer.paddle.force = 0
  end
  self.thisPlayer.paddle:update(dt)
  --update position of other player and ball if update is received from server
  --also if any scoring, then scoringPlayer will be set to the number rep player who
  --scored
  local scoringPlayerNumber = self.udpHandler:updateWorld(self.world, self.playerNumber)
  if scoringPlayerNumber == 1 then
    self.player1.score = self.player1.score + 1
    if self.player1.score == WINNING_SCORE then
      stateManager:change("end", {
        world = self.world,
        udpHandler = self.udpHandler,
        winningPlayer = self.player1,
        thisPlayer = self.thisPlayer,
        playerNumber = self.playerNumber
      })
    else
      self.thisPlayer:resetPaddle()
      stateManager:change("serve", {
        world = self.world,
        udpHandler = self.udpHandler,
        playerNumber = self.playerNumber
      })
    end
  elseif scoringPlayerNumber == 2 then
    self.player2.score = self.player2.score + 1
    if self.player2.score == WINNING_SCORE then
      stateManager:change("end", {
        world = self.world,
        udpHandler = self.udpHandler,
        winningPlayer = self.player2,
        thisPlayer = self.thisPlayer,
        playerNumber = self.playerNumber
      })
    else
      self.thisPlayer:resetPaddle()
      stateManager:change("serve", {
        world = self.world,
        udpHandler = self.udpHandler,
        playerNumber = self.playerNumber
      })
    end
  else
    --handle updating of position with server and requsting update form server
    if self.updateTimer >= 0.03 then
      self.udpHandler:updateServerAndRequestUpdate(self.thisPlayer)
    else
      self.updateTimer = self.updateTimer + dt
    end
  end

  --for playing sounds if any collisions occur - this isnt sent to the server, as the server
  --handles this by itself
  if self.ball:collides(self.player1.paddle) or self.ball:collides(self.player2.paddle) then
    sounds['paddle_hit']:play()
  end

  if self.ball.y <= 0 or self.ball.y >= VIRTUAL_HEIGHT - BALL_HEIGHT then
    sounds['wall_hit']:play()
  end

  if self.ball.x < 0 or self.ball.x > VIRTUAL_WIDTH then
    sounds['score']:play()
  end
end

function PlayState:render()
  --render all objects in the world
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

  --render scores
  displayScore(self.world)
end
