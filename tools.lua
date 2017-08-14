local M = {}

function M.tstring(t)
  local strings = {}
  for k, v in pairs(t) do
    strings[#strings + 1] = tostring(k) .. ': ' .. tostring(v) .. '\n'
  end
  return table.concat(strings, ' ')
end

function M.copy(t)
  local copy = {}
  for k, v in pairs(t) do
    copy[k] = v
  end
  local mt = getmetatable(t)
  if mt then
    setmetatable(copy, mt)
  end
  return copy
end

function M.setdefault(t, k, v)
  if t[k] == nil then
    t[k] = v
  end
  return t[k]
end

function M.contains(t, value)
  for _, v in pairs(t) do
    if v == value then
      return true
    end
  end
  return false
end

function M.length(t)
  local length = 0
  for _, v in pairs(t) do
    length = length + 1
  end
  return length
end

function M.round(num, mult)
  mult = mult or 10
  if num >= 0 then return math.floor(num * mult + 0.5) / mult
  else return math.ceil(num * mult - 0.5) / mult end
end

function M.reverse(t)
  new_t = {}
  for i, v in ipairs(t) do
    new_t[#t - (i - 1)] = v 
  end
  return new_t
end

function M.find_center(size1, size2) 
  return size1 / 2 - size2 / 2
end

return M
