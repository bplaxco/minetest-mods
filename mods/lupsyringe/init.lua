-------------------------------------------------------------------------------
-- Helper Functions -----------------------------------------------------------
-------------------------------------------------------------------------------

local function non_empty_recipes(ingredient)
  --
  -- Generic form for a filled syringe
  --
  return {{
    {"default:steel_ingot"},
    {ingredient},
    {"default:glass"},
  }, {
    {ingredient},
    {"lupsyringe:syringe_empty"},
  }}
end

local function register_sryinge(name, def)
  --
  -- Register a syringe and it's recipes
  --
  local prefix = "lupsyringe:syringe_"

  minetest.register_tool(prefix .. name, {
    description = def.description .. " Syringe",
    inventory_image = def.inventory_image or "lupsyringe_" .. name .. ".png",
    groups = {tool = 1},
    on_use = def.on_use
  })

  for _, recipe in pairs(def.recipes) do
    minetest.register_craft({recipe = recipe, output = prefix .. name})
  end
end

local function delayed_effect(delay, hp, replace_with)
  --
  -- Update inventory before applying the effect
  --
  return function(itemstack, player, pointed_thing)
    if replace_with then
      itemstack = ItemStack(replace_with)
    else
      itemstack:take_item()
    end

    minetest.after(delay, function() player:set_hp(hp) end)

    return itemstack
  end
end

-------------------------------------------------------------------------------
-- Register Syringes ----------------------------------------------------------
-------------------------------------------------------------------------------

register_sryinge("empty", {description = "Empty", recipes = {{
  {"default:steel_ingot"}, {"default:glass"},
}}})

register_sryinge("health", {description = "Health",
  on_use=delayed_effect(1, 20, "lupsyringe:syringe_empty"),
  recipes = non_empty_recipes("flowers:mushroom_brown"),
})

register_sryinge("poison", {description = "Poison",
  on_use=delayed_effect(1, -20, "lupsyringe:syringe_empty"),
  recipes = non_empty_recipes("flowers:mushroom_red"),
})
