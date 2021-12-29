Player = Class{}

-- pass in starting coordiante of player paddle
function Player:init(x, y, width, height)
  self.score = 0
  self.paddle = Paddle(x, y, width, height)
end

-- for rendering in the world, basically just render the paddle of the player
function Player:render()
  self.paddle:render()
end

function Player:resetPaddle()
  print("reseting paddle")
  self.paddle.y = VIRTUAL_HEIGHT / 2 - PADDLE_HEIGHT / 2
  self.paddle.dy = 0
end
