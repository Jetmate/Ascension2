classtools = require 'classtools'
MultiSpriteManager = require 'classes/MultiSpriteManager'
Thing = require 'classes/Thing'

local ComplexMultiSpriteManager = {}
function ComplexMultiSpriteManager:constructor(sprite_sheet, sprites, default_sprite_type, sprite_speeds, directions)
  MultiSpriteManager.constructor(self, sprite_sheet, directions)
  self.sprites = sprites
  self.default_sprite_type = default_sprite_type
  self.sprite_type = default_sprite_type
  self.sprite_speeds = sprite_speeds
end
function ComplexMultiSpriteManager:current_sprites()
  return self.sprites[self.sprite_type]
end
function ComplexMultiSpriteManager:update_sprites(dt, reset)
  if #self:current_sprites() > 1 then
    return MultiSpriteManager.update_sprites(self, dt, self.sprite_speeds[self.sprite_type], reset)
  end
end

classtools.inherit(ComplexMultiSpriteManager, MultiSpriteManager)

return ComplexMultiSpriteManager
