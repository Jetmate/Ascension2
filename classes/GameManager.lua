classtools = require 'classtools'
Quadratic = require 'classes/Quadratic'

GameManager = {}

function GameManager:constructor(
	scales,
	scale_index,
	size,
	level_size,
	transition_speed
)
	self.scales = scales
	self.scale_index = scale_index
	self.size = size
	self.level_size = level_size
	self.transition_speed = transition_speed

	self.phase = 'level'
	self.door = 'entrance'
	self.transition_height = -(self.size[1] / 2 + self.level_size[1] / 2)
  self.transition_quadratics = {
  	Quadratic(Vector(0, 0), Vector(self.transition_speed, self.transition_height)),
  	Quadratic(Vector(self.transition_speed, self.transition_height))
  }
  self.transition_phase = 1
end

function GameManager:scale(direction)
	if not (self.scale_index == 1 and direction == -1) and
		 not (self.scale_index == #self.scales and direction == 1) then
    love.graphics.scale(self.scales[self.scale_index + direction] / self.scales[self.scale_index])
    self.scale_index = self.scale_index + direction
  end
end

function GameManager:reset_transition()
	self.transition_phase = 1
	for _, quadratic in self.transition_quadratics do
		quadratic:reset()
	end
end

classtools.callable(GameManager)

return GameManager
