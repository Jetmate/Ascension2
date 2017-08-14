function class_factory(class, constructor, base_class)
  local class_mt = {__index = class}
  local function new(t, ...)
    local instance = constructor(...)
    return setmetatable(instance, class_mt)
  end
  return setmetatable(class, {__call = new, __index = base_class})
end
a = 2
for k, v in pairs(_ENV) do
  print(k, v)
end
