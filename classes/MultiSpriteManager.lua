classtools = require 'classtools'
SpriteManager = require 'classes/SpriteManager'

local MultiSpriteManager = {}
function MultiSpriteManager:constructor(sprite_sheet, directions)
  SpriteManager.constructor(self, sprite_sheet, directions)
  self:reset_sprites()
end
function MultiSpriteManager:current_sprite()
  return self:current_sprites()[self.sprite_index]
end
function MultiSpriteManager:update_sprites(dt, speed, reset)
  reset = reset or reset == nil
  self.sprite_count = self.sprite_count + dt
  if self.sprite_count >= speed then
    self.sprite_count = 0
    if self.sprite_index == #self:current_sprites() then
      if reset then
        self.sprite_index = 1
      end
      return true
    end
    self.sprite_index = self.sprite_index + 1
  end
  return false
end
function MultiSpriteManager:reset_sprites()
  self.sprite_index = 1
  self.sprite_count = 0
end

classtools.inherit(MultiSpriteManager, SpriteManager)

return MultiSpriteManager
