dofile("./tests/mocks/player.lua")
dofile("./tests/mocks/minetest.lua")
dofile("./tests/mocks/vector.lua")
dofile("./mods/luplights/init.lua")
dofile("./tests/lib/assert.lua")
--
-- Setup
--
local foot = {x = 0, y = 0, z = 0}
local head = {x = 0, y = 1, z = 0}

local function nodename_at(pos)
  return minetest.get_node(pos).name
end
--
-- Air stays air with no light source
--
player.pos = foot
minetest.connected_players = {player}
minetest.globalstep()
minetest.abm()
assert_equal(nodename_at(foot), "air")
assert_equal(nodename_at(head), "air")
--
-- Lightable area is lit with inventory light
--
player.inventory["main"]["luplights:lantern"] = true
minetest.globalstep()
minetest.abm()
assert_equal(nodename_at(foot), "air")
assert_equal(nodename_at(head), "luplights:light_full")
--
-- Clean up light when done
--
player.inventory["main"]["luplights:lantern"] = false
minetest.globalstep()
minetest.abm()
assert_equal(nodename_at(foot), "air")
assert_equal(nodename_at(head), "air")
--
-- Light from wielded item
--
player.inventory.wielded = {get_name = function() return "default:torch" end}
minetest.globalstep()
minetest.abm()
assert_equal(nodename_at(foot), "air")
assert_equal(nodename_at(head), "luplights:light_mid")
--
-- Should clear up when out of hand
--
player.inventory.wielded = nil
minetest.globalstep()
minetest.abm()
assert_equal(nodename_at(foot), "air")
assert_equal(nodename_at(head), "air")
--
-- Light from both
--
player.inventory.wielded = {get_name = function() return "default:torch" end}
player.inventory["main"]["luplights:lantern"] = true
minetest.globalstep()
minetest.abm()
assert_equal(nodename_at(foot), "air")
assert_equal(nodename_at(head), "luplights:light_full")
--
-- Cannot light area that isn't lightable
--
minetest.set_node(head, {name="dirt"})
minetest.globalstep()
assert_equal(nodename_at(foot), "air")
assert_equal(nodename_at(head), "dirt")
--
-- Done!
--
print("luplights passed!")
