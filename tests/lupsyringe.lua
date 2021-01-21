dofile("./tests/mocks/player.lua")
dofile("./tests/mocks/minetest.lua")
dofile("./mods/lupsyringe/init.lua")
dofile("./tests/lib/assert.lua")

--
-- Test Register Tool
--
local function tool_desc(tool_name)
  return minetest.registered_tools[tool_name].description
end

assert_equal(tool_desc("lupsyringe:syringe_health"), "Health Syringe")
assert_equal(tool_desc("lupsyringe:syringe_poison"), "Poison Syringe")
assert_equal(tool_desc("lupsyringe:syringe_empty"), "Empty Syringe")
--
-- Done!
--
print("lupsyringe passed!")
