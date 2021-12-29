EndState = Class{__includes = BaseState}

function EndState:init()
  self.restartOptionMode = true
  self.waitRestartMode = false
end

function EndState:enter(enterParams)
  self.world = enterParams.world
  self.winningPlayer = enterParams.winningPlayer
  self.udpHandler = enterParams.udpHandler
  self.thisPlayer = enterParams.thisPlayer
  self.playerNumber = enterParams.playerNumber
  if self.winningPlayer == self.thisPlayer then
    self.restartOptionMode = false
    self.waitRestartMode = true
  end
end

function EndState:update(dt)
  if self.restartOptionMode then
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
      self.udpHandler:sendRestartMessage()
      self.restartOptionMode = false
      self.waitRestartMode = true
    end
  elseif self.waitRestartMode then
    if self.udpHandler:receiveRestartConfirmation() then
      --reset scores
      self.world.player1.score = 0
      self.world.player2.score = 0
      stateManager:change("serve", {
        udpHandler = self.udpHandler,
        playerNumber = self.playerNumber,
        world = self.world
      })
    end
  end
end

function EndState:render()
  love.graphics.clear(BACKGROUND_COLOR.r, BACKGROUND_COLOR.g, BACKGROUND_COLOR.b)
  love.graphics.setFont(MEDIUM_FONT)
  love.graphics.setColor(INFO_TEXT_COLOR.r, INFO_TEXT_COLOR.g, INFO_TEXT_COLOR.b)
  if self.winningPlayer == self.thisPlayer then
    love.graphics.printf("Congratulations, You WIN!!!", 0,
    TEXT_DISTANCE_FROM_TOP_BORDER, VIRTUAL_WIDTH, 'center')
  else
    love.graphics.printf("Too Bad, You Lose!!!\nPress enter to play again!", 0,
    TEXT_DISTANCE_FROM_TOP_BORDER, VIRTUAL_WIDTH, 'center')
  end
end
