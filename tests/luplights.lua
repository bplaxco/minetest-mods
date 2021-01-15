dofile("./mocks/player.lua")
dofile("./mocks/minetest.lua")
dofile("./mocks/vector.lua")
dofile("./mods/luplights/init.lua")
--
-- Test module
--
assert(luplights, "luplights should exist")
--
-- Test lightable
--
assert(not luplights.lightable(minetest.mock_pos.dirt), "should not be able to light dirt")
assert(luplights.lightable(minetest.mock_pos.air), "should be able to light air")
assert(not luplights.lightable(minetest.mock_pos.light_faint), "should be able to light luplights:light_faint")
assert(not luplights.lightable(minetest.mock_pos.light_dim), "should be able to light luplights:light_dim")
assert(not luplights.lightable(minetest.mock_pos.light_mid), "should be able to light luplights:light_mid")
assert(not luplights.lightable(minetest.mock_pos.light_full), "should be able to light luplights:light_full")
--
-- Test lit
--
assert(not luplights.lit(minetest.mock_pos.dirt), "dirt shouldn't be lit")
assert(not luplights.lit(minetest.mock_pos.air), "air shouldn't be lit")
assert(luplights.lit(minetest.mock_pos.light_faint), "luplights:light_faint should be lit")
assert(luplights.lit(minetest.mock_pos.light_dim), "luplights:light_dim should be lit")
assert(luplights.lit(minetest.mock_pos.light_mid), "luplights:light_mid should be lit")
assert(luplights.lit(minetest.mock_pos.light_full), "luplights:light_full should be lit")
--
-- Test wielded_light_source
--
player.inventory.wielded = {
  get_name = function()
    return "luplights:lantern"
  end
}
assert(minetest.LIGHT_MAX == luplights.wielded_light_source(player), "lantern should set wielded light to max")
player.inventory.wielded = {
  get_name = function()
    return "foo"
  end
}
assert(0 == luplights.wielded_light_source(player), "no item should be wielded")
--
-- Test inventory_light_source
--
player.inventory.main["luplights:lantern"] = true
assert(minetest.LIGHT_MAX == luplights.inventory_light_source(player), "lantern should set inventory light to max")
player.inventory["main"]["luplights:lantern"] = false
assert(0 == luplights.inventory_light_source(player), "0 if lantern not present")
--
-- Test player_light_source
--
assert(0 == luplights.player_light_source(player), "nothing should be emiting light")
player.inventory["main"]["luplights:lantern"] = true
assert(minetest.LIGHT_MAX == luplights.player_light_source(player), "lantern should be emiting light")
player.inventory["main"]["luplights:lantern"] = false
assert(0 == luplights.player_light_source(player), "nothing should be emiting light")
player.inventory.wielded = {
  get_name = function()
    return "luplights:lantern"
  end
}
assert(minetest.LIGHT_MAX == luplights.player_light_source(player), "wielded should be emiting light")
--
-- Test register_light_node
--
luplights.register_light_node("test:test_1")
assert(minetest.registered_nodes["test:test_1"].drawtype == "airlike", "light nodes should be airlike")
assert(minetest.registered_nodes["test:test_1"].light_source == 4, "light nodes should default to 4")
luplights.register_light_node("test:test_1", {light_source = 10})
assert(minetest.registered_nodes["test:test_1"].drawtype == "airlike", "light nodes should be airlike")
assert(minetest.registered_nodes["test:test_1"].light_source == 10, "light nodes should setable")
--
-- Done!
--
print("luplights passed!")
