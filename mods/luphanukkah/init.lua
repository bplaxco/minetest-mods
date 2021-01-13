tnt.register_tnt({
  name = "luphanukkah:dreidel_exploding",
  description = "Just a harmless dreidle",
  raidus = 1,
})

minetest.register_craft({
  output = "luphanukkah:dreidel_exploding",
  recipe = {
    {"default:clay", "default:clay", "default:clay"},
    {"default:clay", "tnt:tnt_stick", "default:clay"},
    {"default:clay", "default:clay", "default:clay"}
  }
})
