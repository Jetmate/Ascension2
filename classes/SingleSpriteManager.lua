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

classtools.inherit(SingleSpriteManager, SpriteManager)

return SingleSpriteManager
