classtools = require 'classtools'
Vector = require 'classes/Vector'

local SpriteManager = {}
function SpriteManager:constructor(sprite_sheet, directions)
  self.sprite_sheet = sprite_sheet
  self.directions = Vector()
  self.offsets = Vector()
  self:change_directions(directions or Vector(1, 1))
end
function SpriteManager:draw(coords)
  love.graphics.draw(self.sprite_sheet, self:display_info(coords))
end
function SpriteManager:display_info(coords)
  coords = coords or self.coords
  return self:current_sprite(),
         coords[0], coords[1],
         self.rotation,
         self.directions[0], self.directions[1],
         self.offsets[0], self.offsets[1]
end
function SpriteManager:sprite_size()
  local x, y, w, h = self:current_sprite():getViewport()
  return Vector(w, h)
end
function SpriteManager:change_directions(directions)
  for i = 0, 1 do
    if directions[i] ~= 0 then
      self.directions[i] = directions[i]
      if directions[i] == -1 then
        self.offsets[i] = self.size[i]
      else
        self.offsets[i] = 0
      end
    end
  end
end

return SpriteManager
