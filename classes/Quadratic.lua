classtools = require 'classtools'
Vector = require 'classes/Vector'

local Quadratic = {}
function Quadratic:constructor(vertex, point)
  if type(vertex) == 'number' then
    point = Vector(1, vertex)
    vertex = Vector()
  end
  point = point or Vector()
  self.h = vertex[0]
  self.k = vertex[1]
  self.a = self.find_a(point[0], point[1], self.h, self.k)
  self:reset()
end
function Quadratic:reset()
  self.current_x = 0
  self.old_y = 0
  self.completed = false
end
function Quadratic:execute(dt)
  self.current_x = self.current_x + dt
  if self.current_x >= self.h then
    self.completed = true
  end
  current_y = self.find_y(self.current_x, self.a, self.h, self.k)
  self.y_change = current_y - self.old_y
  self.old_y = current_y
  return self.y_change
end
function Quadratic:flip()
  self.current_x = self.current_x * -1
end
function Quadratic.find_a(x, y, h, k)
  return (y - k) / (x - h) ^ 2
end
function Quadratic.find_x(y, a, h, k)
    return math.sqrt((y - k) / a) + h
end
function Quadratic.find_y(x, a, h, k)
  return a * (x - h) ^ 2 + k
end

classtools.callable(Quadratic)

return Quadratic
