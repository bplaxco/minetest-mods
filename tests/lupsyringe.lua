dofile("./mocks/player.lua")
dofile("./mocks/minetest.lua")
dofile("./mods/lupsyringe/init.lua")
--
-- Test Register Tool
--
assert(minetest.registered_tools["lupsyringe:syringe_health"].description == "Health Syringe", "should have the right description")
assert(minetest.registered_tools["lupsyringe:syringe_poison"].description == "Poison Syringe", "should have the right description")
assert(minetest.registered_tools["lupsyringe:syringe_empty"].description == "Empty Syringe", "should have the right description")
--
-- Done!
--
print("lupsyringe passed!")
