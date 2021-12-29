Button = Class{}

-- creates a button using a table of arguments, to make some of them, like oneTimeUse, optional
function Button:init(args)
  self.x = args.x
  self.y = args.y
  self.buttonImage = args.image
  self.buttonImagePressed = args.pressedImage or args.image
  self.width = self.buttonImage:getWidth()
  self.height = self.buttonImage:getHeight()
  self.oneTimeUse = args.oneTimeUse
  -- lock for button in case you only want to press it once
  self.locked = args.locked or false
  self.pressedTimer = 0
  self.buttonPressedDownDuration = args.buttonPressedDownDuration or 0.1
  --[[self.link = args.link
  self.action = args.action] ]]
end

-- take action and lock button if it is pressed
function Button:isClicked()
  x, y = love.mouse.getPosition()
  if (x > self.x and x < self.x + self.width and y > self.y and y < self.y + self.height
      and love.mouse.isDown(1)) then
        --self.action(self.link)
        self.locked = true
        return true
  end
end

-- function to unlock button if it is one time use and want to reset it
function Button:unlockButton()
  self.locked = false
end

function Button:update(dt)
  -- increment the timer of button pressed down state until it reaches pressedDownDuration
  if not self.oneTimeUse and self.locked then
    if self.pressedTimer < self.buttonPressedDownDuration then
      self.pressedTimer = self.pressedTimer + dt
    else
      self.locked = false
      self.pressedTimer = 0
    end
  end
  if not self.locked then
    -- check pressed status and take action if pressed
    return self:isClicked()
  end
end

function Button:render()
  if self.locked then
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(self.buttonImagePressed, self.x, self.y)
  else
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(self.buttonImage, self.x, self.y)
  end
end
