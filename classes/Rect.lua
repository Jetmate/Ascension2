classtools = require 'classtools'
Thing = require 'classes/Thing'
Vector = require 'classes/Vector'
tools = require 'tools'

local Rect = {}
function Rect:collided(rect, coords)
  if not coords then coords = self.coords end
  return coords[0] < rect.coords[0] + rect.size[0]
     and rect.coords[0] < coords[0] + self.size[0]
     and coords[1] < rect.coords[1] + rect.size[1]
     and rect.coords[1] < coords[1] + self.size[1]
end
function Rect:inside(rect)
  return self.coords[0] + self.size[0] <= rect.coords[0] + rect.size[0]
     and rect.coords[0] <= self.coords[0]
     and self.coords[1] + self.size[1] <= rect.coords[1] + rect.size[1]
     and rect.coords[1] <= self.coords[1] 
end
function Rect:contains(point)
  return point[0] >= self.coords[0]
     and point[0] < self.coords[0] + self.size[0]
     and point[1] >= self.coords[1]
     and point[1] < self.coords[1] + self.size[1]
end
function Rect:scale(scale_factor)
  self.coords = self.coords * scale_factor
  self.size = self.size * scale_factor
end

local function to_string(t)
  return tostring(t.coords) .. ' ' .. tostring(t.size)
end

setmetatable(Rect, {__tostring = to_string})
classtools.inherit(Rect, Thing)
classtools.callable(Rect)

return Rect
