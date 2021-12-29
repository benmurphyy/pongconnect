Paddle = Class{}

function Paddle:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.dy = 0
    self.force = 0
    self.dyy = 0
end

function Paddle:calcAcclOnPaddle()
  self.frictionalAccl = FRICTION_CONSTANT * self.dy
  self.dyy = self.force + -(self.frictionalAccl)
end
function Paddle:update(dt)
  self:calcAcclOnPaddle()
  --calc speed of paddle based on accleration
  self.dy = self.dy + self.dyy * dt
  if self.dy < 0.1 and self.dy > 0.1 then
    self.dy = 0
  end

    if self.dy < 0 then
        self.y = math.max(0, self.y + self.dy * dt)
    else
        self.y = math.min(VIRTUAL_HEIGHT - self.height, self.y + self.dy * dt)
    end
end

function Paddle:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end
