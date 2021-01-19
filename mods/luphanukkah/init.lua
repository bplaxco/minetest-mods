minetest.register_node("luphanukkah:dreidel_exploding", {
  drawtype = "mesh",
  mesh = "luphanukkah_dreidel.obj",
  description = "Just a harmless dreidel",
  visual = "mesh",
  tiles =  {"luphanukkah_dreidel.png"},
  groups = {tnt = 1, dig_immediate = 2},
  on_punch = function(pos, node, puncher)
		if puncher:get_wielded_item():get_name() == "default:torch" then
      tnt.burn(pos, node.name)
    end
  end,
})

minetest.register_node("luphanukkah:dreidel_exploding_burning", {
  drawtype = "mesh",
  mesh = "luphanukkah_dreidel.obj",
  visual = "mesh",
  on_timer = function(pos, elapsed) tnt.boom(pos, { radius = 2 }) end,
  tiles =  {{
    name = "luphanukkah_dreidel_burning_animated.png",
    animation = {type = "vertical_frames", aspect_w = 32, aspect_h = 32, length = 0.5},
  }},
})

minetest.register_craft({
  output = "luphanukkah:dreidel_exploding",
  recipe = {
    {"default:clay", "default:clay", "default:clay"},
    {"default:clay", "tnt:tnt_stick", "default:clay"},
    {"default:clay", "default:clay", "default:clay"}
  }
})
