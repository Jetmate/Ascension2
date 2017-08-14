classtools = require 'classtools'
Vector = require 'classes/Vector'

local Thing = {}
function Thing:constructor(coords, size, rotation)
  self.coords = coords
  self.size = size or Vector()
  self.rotation = rotation or 0
end

classtools.callable(Thing)

return Thing
