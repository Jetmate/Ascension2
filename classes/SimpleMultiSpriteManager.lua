classtools = require 'classtools'
MultiSpriteManager = require 'classes/MultiSpriteManager'
Thing = require 'classes/Thing'

local SimpleMultiSpriteManager = {}
function SimpleMultiSpriteManager:constructor(sprite_sheet, sprites, speed, directions)
  MultiSpriteManager.constructor(self, sprite_sheet, directions)
  self.sprites = sprites
  self.speed = speed
end
function SimpleMultiSpriteManager:current_sprites()
  return self.sprites
end
function SimpleMultiSpriteManager:update_sprites(dt, reset)
  return MultiSpriteManager.update_sprites(self, dt, self.speed, reset)
end

local function constructor(t, coords, sprite_sheet, sprites, speed, size, directions)
  Thing.constructor(t, coords, size)
  t:constructor(sprite_sheet, sprites, speed, directions)
end

classtools.inherit(SimpleMultiSpriteManager, MultiSpriteManager)
classtools.callable(SimpleMultiSpriteManager)

return SimpleMultiSpriteManager
