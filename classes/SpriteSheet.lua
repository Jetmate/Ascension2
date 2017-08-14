classtools = require 'classtools'
Vector = require 'classes/Vector'

local Spritesheet = {}
function Spritesheet:constructor(sheet)
  self.size = Vector(sheet:getData():getDimensions())
  self.farthest_y = 0
end
function Spritesheet:get_raw_sprite(size, x)
  return love.graphics.newQuad(x, self.farthest_y, size[0],
  size[1], self.size[0], self.size[1])
end
function Spritesheet:get_sprite(size, no_table)
  if not size then
    size = self.size
  end
  local sprite = self:get_raw_sprite(size, 0)
  self.farthest_y = self.farthest_y + size[1]
  if no_table then
    return sprite
  end
  return {sprite}
end
function Spritesheet:get_sprites(size)
  local sprites = {}
  local x = 0
  local max_y = 0
  for _, v in ipairs(size) do
    sprites[#sprites + 1] = self:get_raw_sprite(v, x)
    x = x + v[0]
    if v[1] > max_y then
      max_y = v[1]
    end
  end
  self.farthest_y = self.farthest_y + max_y
  return sprites
end
function Spritesheet:get_similar_sprites(size, constant, index)
  local sprites = {}
  local x = 0
  local max_y = 0
  for _, v in ipairs(size) do
    temp_size = Vector()
    temp_size[index] = constant
    temp_size[Vector.opposite(index)] = v
    sprites[#sprites + 1] = self:get_raw_sprite(temp_size, x)
    x = x + temp_size[0]
    if temp_size[1] > max_y then
      max_y = temp_size[1]
    end
  end
  self.farthest_y = self.farthest_y + max_y
  return sprites
end
function Spritesheet:get_equal_sprites(size, constant)
  local sprites = {}
  local x = 0
  for _ = 1, constant do
    sprites[#sprites + 1] = self:get_raw_sprite(size, x)
    x = x + size[0]
  end
  self.farthest_y = self.farthest_y + size[1]
  return sprites
end

classtools.callable(Spritesheet)

return Spritesheet
