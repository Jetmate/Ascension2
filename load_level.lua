Rect = require 'classes/Rect'
Vector = require 'classes/Vector'

local function load_level(file_name)
  local file = assert(io.open(file_name, 'r'))
  local rects = {}
  while true do
    local c1, c2, d1, d2 = file:read("*n", "*n", "*n", "*n")
    if not c1 then break end
    rects[#rects + 1] = Rect(Vector(c1, c2), Vector(d1, d2))
  end
  file:close()
  return rects
end

return load_level
