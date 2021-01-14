dofile("./mocks/player.lua")
dofile("./mocks/minetest.lua")
dofile("./mocks/vector.lua")
dofile("./mods/luplights/init.lua")

-- Test module
assert(luplights, "luplights should exist")

-- Test lightable
assert(not luplights.lightable(minetest.mock_pos.dirt), "should not be able to light dirt")
assert(luplights.lightable(minetest.mock_pos.air), "should be able to light air")
assert(luplights.lightable(minetest.mock_pos.light_faint), "should be able to light luplights:light_faint")
assert(luplights.lightable(minetest.mock_pos.light_dim), "should be able to light luplights:light_dim")
assert(luplights.lightable(minetest.mock_pos.light_mid), "should be able to light luplights:light_mid")
assert(luplights.lightable(minetest.mock_pos.light_full), "should be able to light luplights:light_full")

-- Test inventory_light_source
player.inventory.main["luplights:lantern"] = true
assert(minetest.LIGHT_MAX == luplights.inventory_light_source(player), "lantern should set inventory light to max")

player.inventory["main"]["luplights:lantern"] = false
assert(0 == luplights.inventory_light_source(player), "0 if lantern not present")

-- Test register_light_point
luplights.register_light_point("test:test_1")
assert(minetest.registered_nodes["test:test_1"].drawtype == "airlike", "light points should be airlike")
assert(minetest.registered_nodes["test:test_1"].light_source == 4, "light points should default to 4")

luplights.register_light_point("test:test_1", {light_source = 10})
assert(minetest.registered_nodes["test:test_1"].drawtype == "airlike", "light points should be airlike")
assert(minetest.registered_nodes["test:test_1"].light_source == 10, "light points should setable")

-- Test init_player_light and light_pos
player.name = "test"
player.pos = {x=1, y=2, z=3}
luplights.init_player_light(player)

assert(luplights.player_lights["test"].pos.x == 1, "should be the same vector")
assert(luplights.light_pos(player).x == 1, "should be the same vector")
player.name = "bar"
assert(not luplights.light_pos(player), "should not exist")

-- Test remove_player_light
player.name = "test"
luplights.remove_player_light(player)
assert(not luplights.player_lights["test"], "should not be present")

-- Done!
print("luplights passed!")
