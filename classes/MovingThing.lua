classtools = require 'classtools'
tools = require 'tools'
Vector = require 'classes/Vector'

local MovingThing = {}
function MovingThing:constructor(velocity)
  self.velocity = velocity or Vector()
end
function MovingThing:new_coords()
  return self.coords + self.velocity
end
function MovingThing:update_coords()
  self.coords = self:new_coords()
end
-- function MovingThing:display_coords()
--   local coords = Vector()
--   for i = 0, 1 do
--     coords[i] = tools.round(self.coords[i])
--     if coords[i] % 1 == .5 then
--       coords[i] = coords[i] + .6
--     end
--   end
--   -- print(coords)
--   return coords
-- end
function MovingThing:reset_velocity()
  self.velocity = Vector()
end

classtools.callable(MovingThing)

return MovingThing
