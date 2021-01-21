vector = {}

function vector.round(pos)
  return vector.new(pos)
end

function vector.new(pos)
  return {x=pos.x, y=pos.y, z=pos.z}
end

function vector.equals(a, b)
  return a.x == b.x and a.y == b.y and a.z == b.z
end
