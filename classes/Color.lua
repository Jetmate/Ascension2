classtools = require 'classtools'

local Color = {}
function Color:constructor(r, g, b, a)
  self.r = r
  self.g = g
  self.b = b
  self.a = a or 255
end

function Color:expand()
  return self.r, self.g, self.b, self.a
end

local function equality(a, b)
  return a.r == b.r
     and a.g == b.g
     and a.b == b.b
     and a.a == b.a
end
local function to_string(t)
  return tostring(t.r) .. ' ' .. tostring(t.g) .. ' ' .. tostring(t.b)
end

setmetatable(Color, {__eq = equality, __tostring = to_string})
classtools.callable(Color)

return Color
