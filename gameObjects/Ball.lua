Ball = Class{}

function Ball:init(x, y)
  self.x = x
  self.y = y
  self.width = BALL_WIDTH
  self.height = BALL_HEIGHT
end

function Ball:render()
  love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end

function Ball:collides(paddle)
    -- first, check to see if the left edge of either is farther to the right
    -- than the right edge of the other
    if self.x > paddle.x + paddle.width or paddle.x > self.x + self.width then
        return false
    end

    -- then check to see if the bottom edge of either is higher than the top
    -- edge of the other
    if self.y > paddle.y + paddle.height or paddle.y > self.y + self.height then
        return false
    end

    -- if the above aren't true, they're overlapping
    return true
end
