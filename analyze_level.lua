Rect = require 'classes/Rect'
Vector = require 'classes/Vector'
Color = require 'classes/Color'

local function check_collision(rects, vector)
  local collided = false
  for _, v in ipairs(rects) do
    if v:contains(vector) then
      collided = true
      break
    end
  end
  return collided
end

local function analyze_level(file_name, image, types, color_values)
  local file = assert(io.open(file_name, 'w'))
  local image_size = Vector(image:getsize())
  
  local blocks = {}
  local current_vector, color, rect, collided, y1, is_solid
  for y = 0, image_size[1] - 1 do
    for x = 0, image_size[0] - 1 do
      current_vector = Vector(x, y)
      color = Color(image:getcolor(x, y))

      collided = check_collision(rects, current_vector)
      is_solid = tools.contains(types.solid, color)
      if not rect then
        if is_solid and not collided then
            rect = Rect(current_vector)
        end
      else 
        if not is_solid or x == image_size[0] - 1 or collided then
          if not is_solid or collided then
            x = x - 1
          end
          y1 = y
          if y ~= image_size[1] - 1 then
            repeat
              y1 = y1 + 1
              color = Color(image:getcolor(x, y1))
            until not tools.contains(types.solid, color) or y1 == image_size[1] - 1
          end
          rect.size = Vector(x + 1, y1 + 1) - rect.coords
          file:write(tostring(rect), '\n')
          rect = nil
        end
      end

      if color.a == 255 then
        if color_vales[tostring(color)] then
          if not blocks[x] then
            blocks[x] = {}
          end
          blocks[x][y] = color_values[tostring(color)] 
        else
          error('Unidentified block_color ', tostring(color), ' at ', tostring(current_vector))
        end
      end
    end
  end

  file:write("NEXT")

  for x in blocks do
    for y in blocks[x] do
      current_vector = Vector(x, y)
      file:write(blocks[x][y], ' ', tostring(current_vector), '\n')
    end
  end

  file:close()
end

return analyze_level