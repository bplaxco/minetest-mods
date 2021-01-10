minetest.register_tool("lupsyringe:syringe_health", {
	description = "Health Syringe",
	inventory_image = "lupsyringe_health.png",
	groups = {tool = 1},
  on_use = minetest.item_eat(20, "lupsyringe:syringe_empty 1"),
})

minetest.register_craftitem("lupsyringe:syringe_empty", {
	description = "Empty Syringe",
	inventory_image = "lupsyringe_empty.png",
	groups = {tool = 1},
})

minetest.register_craft({
	output = "lupsyringe:syringe_empty",
	recipe = {
		{"default:steel_ingot"},
		{"default:glass"},
	}
})

minetest.register_craft({
	output = "lupsyringe:syringe_health",
	recipe = {
		{"default:steel_ingot"},
		{"group:flora"},
		{"default:glass"},
	}
})

minetest.register_craft({
	output = "lupsyringe:syringe_health",
	recipe = {
		{"group:flora"},
		{"lupsyringe:syringe_empty"},
	}
})
