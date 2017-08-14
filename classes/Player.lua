classtools = require 'classtools'
ComplexMultiSpriteManager = require 'classes/ComplexMultiSpriteManager'
Rect = require 'classes/Rect'
MovingThing = require 'classes/MovingThing'
Quadratic = require 'classes/Quadratic'

local Player = {}
function Player:constructor(
  coords,
  fake_coords,
  size,
  sprite_sheet,
  sprites,
  default_sprite_type,
  sprite_speeds,
  keys,
  movement_speed,
  jump_vector,
  fall_speed,
  wall_jump_vector
)
  Rect.constructor(self, coords, size)
  ComplexMultiSpriteManager.constructor(self, sprite_sheet, sprites, default_sprite_type, sprite_speeds)
  MovingThing.constructor(self)
  self.default_coords = coords
  self.fake_coords = fake_coords
  self.keys = keys
  self.movement_speed = movement_speed
  self.jump_vector = jump_vector
  self.fall_speed = fall_speed
  self.wall_jump_vector = wall_jump_vector
  self.dead = false
  -- self.can_jump = true
end
function Player:move(dt)
  if self.direction then
    if self.direction == 1 then
      self.velocity[0] = self.velocity[0] + self.movement_speed * dt
    elseif self.direction == -1 then
      self.velocity[0] = self.velocity[0] + -self.movement_speed * dt
    end
  end
  if self.condition then
    self.velocity[1] = self.velocity[1] + self.quadratic:execute(dt)
    if self.condition == 'jumping' and self.quadratic.completed then
      self.condition = nil
    end
  end
  if self.horizontal_quadratic then
    self.velocity[0] = self.velocity[0] + self.horizontal_quadratic:execute(dt)
    if self.horizontal_quadratic.completed then
      self.horizontal_quadratic = nil
    end
  end
end
function Player:jump()
  if self.rect or self.wall_direction then
    -- self.can_jump = false
    self.quadratic = Quadratic(self.jump_vector)
    if self.rect then 
      self.condition = 'jumping'
    elseif self.wall_direction then
      self.horizontal_quadratic = Quadratic(self.wall_jump_vector * Vector(1, self.wall_direction))
    end
  end
  -- elseif not self.rect then
  --   self.can_jump = false
  -- end
end
function Player:fall()
  self.condition = 'falling'
  self.quadratic = Quadratic(self.fall_speed)
end
function Player:process_collision(rect)
  local velocity
  for i = 0, 1 do
    velocity = Vector()
    velocity[i] = self.velocity[i]
    if self:collided(rect, self.coords + velocity) then
      self:align_coords(rect, i)
      self.velocity[i] = 0
      return
    end
  end
end
function Player:align_coords(rect, i)
  local direction
  if self.velocity[i] > 0 then
    self.coords[i] = rect.coords[i] - self.size[i]
    direction = 1
  elseif self.velocity[i] < 0 then
    self.coords[i] = rect.coords[i] + rect.size[i]
    direction = -1
  else
    error("Player collision without velocity")
  end
  if i == 0 then
    self.wall_direction = direction * -1
  else
    self.condition = nil
    if self.velocity[i] > 0 then
      self.rect = rect
      -- self.can_jump = tru
    end
  end
end
function Player:on_ground()
  return self:collided(self.rect, self.coords + Vector(0, 1))
end
function Player:update_sprite_type()
  local sprite_type
  if self.dead then
    sprite_type = 'dying'
  elseif self.wall_direction then
    if not self.rect then
      sprite_type = 'sliding'
    else
      sprite_type = 'pressing'
    end
  elseif not self.rect then
    sprite_type = 'jumping'
  elseif self.direction then
    sprite_type = 'moving'
  else
    sprite_type = 'idle'
  end
  if sprite_type ~= self.sprite_type then
    self.sprite_type = sprite_type
    self:reset_sprites()
  end
end
function Player:slide()
  self:change_directions(Vector(self.wall_direction, 0))
  -- self.can_jump = true
end
function Player:display()
  self:draw(Vector())
end
function Player:reset()
  self:reset_sprites()
  self.coords = self.default_coords
  self.dead = false
end

classtools.inherit(Player, ComplexMultiSpriteManager, Rect, MovingThing)
classtools.callable(Player)

return Player
