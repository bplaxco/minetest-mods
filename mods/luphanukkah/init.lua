minetest.register_node("luphanukkah:dreidel_exploding", {
  drawtype = "mesh",
  mesh = "luphanukkah_dreidel.obj",
  description = "Just a harmless dreidel",
  visual = "mesh",
  tiles =  {"luphanukkah_dreidel.png"},
})

minetest.register_node("luphanukkah:dreidel_exploding_lit", {
  drawtype = "mesh",
  mesh = "luphanukkah_dreidel.obj",
  visual = "mesh",
  tiles =  {{
    name = "luphanukkah_dreidel_lit_animated.png",
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
