StateManager = Class{__includes = BaseState}

function StateManager:init(states)
	self.empty = {
		render = function() end,
		update = function() end,
		enter = function() end,
		exit = function() end
	}
	self.states = states or {} -- [name] -> [function that returns states]
	self.current = self.empty
end

function StateManager:change(stateName, enterParams)
	assert(self.states[stateName]) -- state must exist!
	self.current:exit()
	self.current = self.states[stateName]()
	self.current:enter(enterParams)
end

function StateManager:update(dt)
	self.current:update(dt)
end

function StateManager:render()
	self.current:render()
end
