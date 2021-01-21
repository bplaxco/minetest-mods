local function pos_key(pos)
  return pos.x .. "." .. pos.y .. "." .. pos.z
end

local function key_pos(key)
  local i = 0
  local pos = {}

  for num in key:gmatch("%d+") do
    if i == 0 then
      pos.x = tonumber(num)
    elseif i == 1 then
      pos.y = tonumber(num)
    elseif i == 2 then
      pos.z = tonumber(num)
    end

    i = i + 1
  end

  return pos
end

minetest = {
  LIGHT_MAX = 14,
  connected_players = {},
  nodes = {},
  registered_crafts = {},
  registered_nodes = {},
  registered_tools = {},
}


function minetest.register_node(name, def)
  minetest.registered_nodes[name] = def
end

function minetest.register_craft(name, def)
  minetest.registered_crafts[name] = def
end

function minetest.register_tool(name, def)
  minetest.registered_tools[name] = def
end

function minetest.register_globalstep(f)
  minetest.globalstep = f
end

function minetest.register_abm(def)
  minetest.abm = function()
    for _, nodename in pairs(def.nodenames) do
      for k, node in pairs(minetest.nodes) do
        if node.name == nodename then
          def.action(key_pos(k))
        end
      end
    end
  end
end

function minetest.get_node(pos)
  return minetest.nodes[pos_key(pos)] or {
    name = "air",
  }
end

function minetest.set_node(pos, node)
  minetest.nodes[pos_key(pos)] = node
end

function minetest.remove_node(pos)
  minetest.set_node(pos, nil)
end

function minetest.get_connected_players()
  return minetest.connected_players
end

function minetest.item_eat()
end

minetest.register_node("default:torch", {light_source = 11})
