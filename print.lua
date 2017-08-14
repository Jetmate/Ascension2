local debug = assert(io.open('/home/jetmate/programming/lua/grasswarriors/debug.txt', 'w'))
debug:close()

local function print(...)
  debug = assert(io.open('/home/jetmate/programming/lua/grasswarriors/debug.txt', 'a'))
  for _, v in ipairs({...}) do
    debug:write(tostring(v), ' ')
  end
  debug:close()
end

return print
