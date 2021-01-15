minetest = {
  LIGHT_MAX = 14,
  registered_nodes = {},
  registered_tools = {},
  mock_pos = {
    dirt = "dirt", air = "air",
    light_faint = "luplights:light_faint",
    light_dim = "luplights:light_dim",
    light_mid = "luplights:light_mid",
    light_full = "luplights:light_full",
  },
}

function minetest.register_node(name, def)
  minetest.registered_nodes[name] = def
end

function minetest.register_craft()
end

function minetest.register_tool(name, def)
  minetest.registered_tools[name] = def
end

function minetest.register_on_joinplayer()
end

function minetest.register_on_leaveplayer()
end

function minetest.register_globalstep()
end

function minetest.register_abm()
end

function minetest.get_node(pos)
  return {name = pos}
end

function minetest.get_connected_players(pos)
  return {player}
end

function minetest.item_eat()
end
