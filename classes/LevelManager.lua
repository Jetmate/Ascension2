classtools = require 'classtools'
tools = require 'tools'
Tile = require 'classes/Tile'
Vector = require 'classes/Vector'
Color = require 'classes/Color'

local LevelManager = {}

function LevelManager:constructor(
  map_sheet,
  direction_sheet,
  level_size, 
  tile_size, 
  sprite_sheet, 
  sprites, 
  sprite_speeds, 
  default_sprite_speed, 
  color_values,
  offsets, 
  types,
  direction_values
)
	self.map_sheet = map_sheet
  self.direction_sheet = direction_sheet
  self.level_size = level_size
  self.tile_size = Vector(tile_size, tile_size)
  self.tile_width = tile_size
  self.tile_sprite_batch = love.graphics.newSpriteBatch(sprite_sheet, level_size[0] ^ 2)
  self.sprites = sprites
  self.sprite_speeds = sprite_speeds
  self.default_sprite_speed = default_sprite_speed
  self.color_values = color_values
  self.offsets = offsets
  self.types = types
  self.direction_values = direction_values

  self.level = 0
  self.directions = {Vector(-1, 0), Vector(1, 0), Vector(0, -1), Vector(0, 1)}
  self.background_color = Color(sprite_sheet:getData():getPixel(self.sprites['background'][1]:getViewport()))
end

local function check_collision(rects, vector)
  local collided = false
  for _, v in pairs(rects) do
    if v:contains(vector) then
      collided = true
      break
    end
  end
  return collided
end

function LevelManager:convert_to_grid(grid_coords)
  return (grid_coords - grid_coords % self.tile_size) / self.tile_size
end

function LevelManager:convert_from_grid(grid_coords)
  return grid_coords * self.tile_size
end

function LevelManager:surrounding_tiles(grid_coords)
  return function(grid_coords, i) 
    if i < 4 then
      return i + 1, grid_coords + self.directions[i + 1]
    end
  end, grid_coords, 0
end

function LevelManager:load_level()
  self.level = self.level + 1
  
  local entrance
  self.rects = {}
  local tiles = {}
  do
    local grid_coords, color, rect, x1, y1, is_solid, open, tile_type
    for x = 0, self.level_size[0] - 1 do
      for y = 0, self.level_size[1] - 1 do
        grid_coords = Vector(x, y)
        color = Color(self.map_sheet:getPixel(x, y))

        is_solid = nil
        if color.a == 255 then
          is_solid = self:of_type('solid', color)
          if self.color_values[tostring(color)] then
            tile_type = self.color_values[tostring(color)]
            tools.setdefault(tiles, x, {})[y] = tile_type
            if tile_type == 'entrance' then
              entrance = grid_coords
            end
          else
            error('Unidentified tile color ' .. tostring(color) .. ' at ' .. tostring(grid_coords))
          end
        end

        open = is_solid and not check_collision(self.rects, grid_coords)

        if not rect then
          if open then
              rect = Rect(grid_coords)
          end

        else
          if not open or y == self.level_size[1] - 1 then
            if not open then y = y - 1 end
            x1 = x
            open = true

            while x1 ~= self.level_size[0] - 1 and open do
              x1 = x1 + 1
              for y1 = rect.coords[1], y do
                color = Color(self.map_sheet:getPixel(x1, y1))
                open = color.a == 255 and self:of_type('solid', color)
                       and not check_collision(self.rects, Vector(x1, y1))
                if not open then break end
              end
            end

            if not open then x1 = x1 - 1 end
            rect.size = Vector(x1 + 1, y + 1) - rect.coords
            self.rects[#self.rects + 1] = tools.copy(rect)
            rect = nil
          end
        end
      end
    end
  end

  for _, rect in pairs(self.rects) do
    rect.coords = self:convert_from_grid(rect.coords)
    rect.size = self:convert_from_grid(rect.size)
  end

  self.backgrounds = {}
  do
    local backgrounds = {}
    local active_coords = {entrance}
    local new_coords
    while #active_coords > 0 do
      new_coords = {}
      for _, coords in pairs(active_coords) do
        for _, coords2 in self:surrounding_tiles(coords) do
          if not tools.contains(backgrounds, tostring(coords2)) 
             and self.value(tiles, coords2) ~= 'block' 
             and self.level_size:contains(coords2) then
            self.backgrounds[#self.backgrounds + 1] = self:new_tile(coords2, 'background')
            backgrounds[#backgrounds + 1] = tostring(coords2)
            new_coords[#new_coords + 1] = tools.copy(coords2)
          end
        end
      end
      active_coords = new_coords
    end
  end

  self.tiles = {}
  do
    local blocks = {} 
    do
      local coords, result, tile
      for x, y_tiles in pairs(tiles) do
        for y, tile_type in pairs(y_tiles) do
          coords = Vector(x, y)

          if tile_type == 'block' then
            result = ''
            for i, coords in self:surrounding_tiles(coords) do
              if self.level_size:contains(coords) and not self:of_type('solid', self.value(tiles, coords)) then
                result = result .. tostring(i)
              end
            end
            tools.setdefault(blocks, result, {})[#blocks[result] + 1] = tools.copy(coords)
          
          else
            tile = self:new_tile(coords, tile_type)
            self.tiles[#self.tiles + 1] = tile
            if tile_type == 'entrance' then
              self.entrance = tile
            elseif tile_type == 'exit' then
              self.exit = tile
            end
          end
        end
      end
    end

    local block_canvas_size = Vector(tools.length(blocks) * self.tile_width, self.tile_width)
    local block_canvas = love.graphics.newCanvas(block_canvas_size[0], block_canvas_size[1])
    love.graphics.setCanvas(block_canvas)

    do
      local x = 0
      local direction, rect_coords, rect_size, sprite
      for surrounding_blocks, block_list in pairs(blocks) do
        love.graphics.draw(self.tile_sprite_batch:getTexture(), self.sprites.block[1], x, 0)
        
        love.graphics.setColor(0, 0, 0)
        for i_string = 1, #surrounding_blocks do
          direction = self.directions[tonumber(string.sub(surrounding_blocks, i_string, i_string))]
          rect_coords = Vector()
          if direction:direction() == 1 then
            rect_coords[direction.direction_index] = self.tile_width - 1
          end
          rect_size = Vector()
          rect_size[direction.direction_index] = 1
          rect_size[direction:zero_index()] = self.tile_width
          love.graphics.rectangle('fill', rect_coords[0] + x, rect_coords[1], rect_size[0], rect_size[1])
        end
        
        love.graphics.setColor(self.background_color:expand())
        if string.find(surrounding_blocks, '1') then
          if string.find(surrounding_blocks, '3') then
            love.graphics.rectangle('fill', x, 0, 1, 1)
          end
          if string.find(surrounding_blocks, '4') then
            love.graphics.rectangle('fill', x, self.tile_width - 1, 1, 1)
          end
        end
        if string.find(surrounding_blocks, '2') then 
          if string.find(surrounding_blocks, '3') then
            love.graphics.rectangle('fill', x + self.tile_width - 1, 0, 1, 1)
          end
          if string.find(surrounding_blocks, '4') then
            love.graphics.rectangle('fill', x + self.tile_width - 1, self.tile_width - 1, 1, 1)
          end
        end
        love.graphics.setBlendMode('alpha')

        love.graphics.setColor(255, 255, 255)
        sprite = love.graphics.newQuad(
          x, 0, 
          self.tile_width, self.tile_width,
          block_canvas_size[0], block_canvas_size[1]
        )
        for _, grid_coords in pairs(block_list) do
          self.tiles[#self.tiles + 1] = self:new_tile(grid_coords, 'block', {sprite})
        end
        x = x + self.tile_width
      end
    end
    love.graphics.setCanvas()
    self.block_sprite_batch = love.graphics.newSpriteBatch(block_canvas, self.level_size[0] ^ 2)
  end
end

function LevelManager:of_type(tile_type, tile)
  if type(tile) == 'table' then
    tile = self.color_values[tostring(tile)]
  end
  if tools.contains(self.types[tile_type], tile) then
    return true
  else
    return false  
  end
end

function LevelManager:new_tile(grid_coords, tile_type, sprites, direction)
  local sprites = sprites or self.sprites[tile_type]
  local coords = self:convert_from_grid(grid_coords)
  if self.offsets[tile_type] then
    coords = coords + self.offsets[tile_type]
  end
  local sprite_speed = self.sprite_speeds[tile_type] or self.default_sprite_speed
  local rotation = self:find_direction(grid_coords, tile_type)
  return Tile(
    coords,
    self.size(sprites[1]),
    tile_type,
    sprites,
    sprite_speed,
    rotation
  )
end

function LevelManager:find_direction(grid_coords, tile_type)
  -- print(grid_coords, tile_type)
  if self:of_type('directional', tile_type) then
    return self.direction_values[tostring(Color(self.direction_sheet:getPixel(grid_coords:expand())))]
  end
end

function LevelManager:display(player_coordinates)
  self.tile_sprite_batch:clear()
  self.block_sprite_batch:clear()

  for _, background in pairs(self.backgrounds) do
    self.tile_sprite_batch:add(background:display_info())    
  end
  
  for _, tile in pairs(self.tiles) do
    if tile.type == 'block' then
      self.block_sprite_batch:add(tile:display_info())
    else
      self.tile_sprite_batch:add(tile:display_info())
    end
  end

  love.graphics.draw(
    self.tile_sprite_batch, 
    0, 0,
    0,
    1, 1,
    player_coordinates[0], player_coordinates[1]
  )

  love.graphics.draw(
    self.block_sprite_batch, 
    0, 0,
    0,
    1, 1,
    player_coordinates[0], player_coordinates[1]
  )
end

function LevelManager:door_coords(door, player)
  -- print(player.coords, player.size, self[door].coords, self[door].size, self[door].coords[1] + self[door].size[1] - player.size[1] )
  return Vector(
    self[door].coords[0] + tools.find_center(self[door].size, player.size)[0],
    self[door].coords[1] + self[door].size[1] - player.size[1]
  )
end

function LevelManager.value(table, grid_coords)
  if table[grid_coords[0]] ~= nil then
    return table[grid_coords[0]][grid_coords[1]]
  end
end

function LevelManager.size(quad)
  x, y, w, h = quad:getViewport()
  return Vector(w, h)
end

classtools.callable(LevelManager)

return LevelManager
