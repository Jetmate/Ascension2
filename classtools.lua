tools = require 'tools'

local function search(k, list)
  for _, v in ipairs(list) do
    local result = v[k]
    if result then return result end
  end
end
local function metatable_check(f)
  return function(class, ...)
    if not getmetatable(class) then
      setmetatable(class, {})
    end
    f(class, ...)
  end
end
local function parent_function(parents)
  if #parents == 1 then
    parent = parents[1]
  else
    parent = function(t, k)
      return search(k, parents)
    end
  end
  return parent
end

local M = {}

M.inherit = metatable_check(
function(class, ...)
  getmetatable(class).__index = parent_function({...})
end
)

M.callable = metatable_check(
function(class)
  local instance_mt = tools.copy(getmetatable(class))
  instance_mt.__index = class

  local function new(t, ...)
    local instance = setmetatable({}, instance_mt)
    instance:constructor(...)
    return instance
  end
  getmetatable(class).__call = new
end
)

return M
