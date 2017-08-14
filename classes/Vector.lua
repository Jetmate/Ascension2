classtools = require 'classtools'

local Vector = {}
function Vector:constructor(x, y)
  self[0] = x or 0
  self[1] = y or 0
  if self[0] == 0 and self[1] ~= 0 then
    self.direction_index = 1
  elseif self[1] == 0 and self[0] ~= 0 then
    self.direction_index = 0
  end
end
function Vector:direction()
  return self[self.direction_index]
end
function Vector:zero_index()
  return math.abs(self.direction_index - 1)
end
function Vector:expand()
  return self[0], self[1]
end
function Vector:contains(point)
  return point[0] >= 0
     and point[0] < self[0]
     and point[1] >= 0
     and point[1] < self[1]
end
local function add(a, b)
  if type(b) == 'number' then
    return Vector(a[0] + b, a[1] + b)
  else
    return Vector(a[0] + b[0], a[1] + b[1])
  end
end
local function subtract(a, b)
  if type(b) == 'number' then
    return Vector(a[0] - b, a[1] - b)
  else
    return Vector(a[0] - b[0], a[1] - b[1])
  end
end
local function multiply(a, b)
  if type(b) == 'number' then
    return Vector(a[0] * b, a[1] * b)
  else
    return Vector(a[0] * b[0], a[1] * b[1])
  end
end
local function divide(a, b)
  if type(b) == 'number' then
    return Vector(a[0] / b, a[1] / b)
  else
    return Vector(a[0] / b[0], a[1] / b[1])
  end
end
local function modulo(a, b)
  if type(b) == 'number' then
    return Vector(a[0] % b, a[1] % b)
  else
    return Vector(a[0] % b[0], a[1] % b[1])
  end
end
local function to_string(t)
  return t[0] .. ' ' .. t[1]
end

setmetatable(Vector, {
  __add = add,
  __sub = subtract,
  __mul = multiply,
  __div = divide,
  __mod = modulo,
  __tostring = to_string,
})
classtools.callable(Vector)

return Vector
