classtools = require 'classtools'
Thing = require 'classes/Thing'

local SingleSpriteManager = {}
function SingleSpriteManager:constructor(sprite_sheet, sprite, directions)
  SpriteManager.constructor(self, sprite_sheet, directions)
  self.sprite = sprite
end
function SingleSpriteManager:current_sprite()
  return self.sprite
end

local function constructor(t, coords, sprite_sheet, sprite, size, directions)
  Thing.constructor(t, coords, size)
  t:constructor(sprite_sheet, sprite, directions)
end

classtools.inherit(SingleSpriteManager, SpriteManager)
classtools.callable(SingleSpriteManager, constructor, Thing)

return SingleSpriteManager
