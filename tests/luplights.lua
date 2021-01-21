dofile("./mocks/player.lua")
dofile("./mocks/minetest.lua")
dofile("./mocks/vector.lua")
dofile("./mods/luplights/init.lua")
--
-- Air stays air with no light source
--
player.pos = {x = 0, y = 0, z = 0}
minetest.connected_players = {player}
minetest.globalstep()
minetest.abm()
assert(minetest.get_node({x = 0, y = 0, z = 0}).name == "air", "should be air")
assert(minetest.get_node({x = 0, y = 1, z = 0}).name == "air", "should be air")
--
-- Lightable area is lit with inventory light
--
player.inventory["main"]["luplights:lantern"] = true
minetest.globalstep()
minetest.abm()
assert(minetest.get_node({x = 0, y = 0, z = 0}).name == "air", "should be air")
assert(minetest.get_node({x = 0, y = 1, z = 0}).name == "luplights:light_full", "should be a light block")
--
-- Clean up light when done
--
player.inventory["main"]["luplights:lantern"] = false
minetest.globalstep()
minetest.abm()
assert(minetest.get_node({x = 0, y = 0, z = 0}).name == "air", "should be air")
assert(minetest.get_node({x = 0, y = 1, z = 0}).name == "air", "should be air")
--
-- Light from wielded item
--
player.inventory.wielded = {get_name = function() return "default:torch" end}
minetest.globalstep()
minetest.abm()
assert(minetest.get_node({x = 0, y = 0, z = 0}).name == "air", "should be air")
assert(minetest.get_node({x = 0, y = 1, z = 0}).name == "luplights:light_mid", "should be a light block")
--
-- Should clear up when out of hand
--
player.inventory.wielded = nil
minetest.globalstep()
minetest.abm()
assert(minetest.get_node({x = 0, y = 0, z = 0}).name == "air", "should be air")
assert(minetest.get_node({x = 0, y = 1, z = 0}).name == "air", "should be air")
--
-- Light from both
--
player.inventory.wielded = {get_name = function() return "default:torch" end}
player.inventory["main"]["luplights:lantern"] = true
minetest.globalstep()
minetest.abm()
assert(minetest.get_node({x = 0, y = 0, z = 0}).name == "air", "should be air")
assert(minetest.get_node({x = 0, y = 1, z = 0}).name == "luplights:light_full", "should be a light block")
--
-- Cannot light area that isn't lightable
--
minetest.set_node({x = 0, y = 1, z = 0}, {name="dirt"})
minetest.globalstep()
assert(minetest.get_node({x = 0, y = 0, z = 0}).name == "air", "should be air")
assert(minetest.get_node({x = 0, y = 1, z = 0}).name == "dirt", "shouldn't be lightable")
--
-- Done!
--
print("luplights passed!")
