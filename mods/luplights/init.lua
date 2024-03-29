-------------------------------------------------------------------------------
-- Define the luplights API ---------------------------------------------------
-------------------------------------------------------------------------------

local function inventory_light_source(player)
  --
  -- Returns eligible inventory light source values
  --
  if player:get_inventory():contains_item("main", "luplights:lantern") then
    return minetest.registered_nodes["luplights:lantern"].light_source
  else
    return 0
  end
end

local function wielded_light_source(player)
  --
  -- Return the light source value of the wielded item
  --
  local wielded = minetest.registered_nodes[player:get_wielded_item():get_name()]
  return wielded and wielded.light_source or 0
end

local function player_light_source(player)
  --
  -- Return the effective light source value for the player
  --
  local inventory = inventory_light_source(player)

  if inventory == minetest.LIGHT_MAX then
    return inventory
  end

  local wielded = wielded_light_source(player)

  if wielded > inventory then
    return wielded
  else
    return inventory
  end
end

local function lightable(pos)
  --
  -- Can a light block be placed here
  --
  return minetest.get_node(pos).name == "air"
end

local function lit(pos)
  --
  -- This area is lit
  --
  local name = minetest.get_node(pos).name

  return (
    name == "luplights:light_full" or name == "luplights:light_mid" or
    name == "luplights:light_dim" or name == "luplights:light_faint"
  )
end

local function player_area_match(player, matches)
  --
  -- Return a position that the match function returns true on
  --
  local pos = vector.round(player:get_pos())
  pos.y = pos.y + 1

  if matches(pos) then
    return pos
  else
    return nil
  end
end

local function garbage_collect_light_nodes(pos)
  --
  -- Garbage collect light sources as the player moves away from them
  --
  for _, player in ipairs(minetest.get_connected_players()) do
    local light_pos = player_area_match(player, lit)
    if light_pos and vector.equals(light_pos, pos) and player_light_source(player) > 0 then
      return
    end
  end

  minetest.remove_node(pos)
end

local function emit_player_light(player)
  --
  -- Emit light as a player
  --
  if player_area_match(player, lit) then
    return
  end

  local pos = player_area_match(player, lightable)

  if not pos then
    return
  end

  local light = player_light_source(player)

  if light == 0 then
    return
  end

  if light > 13 then
    minetest.set_node(pos, {name = "luplights:light_full"})
  elseif light > 10 then
    minetest.set_node(pos, {name = "luplights:light_mid"})
  elseif light > 7 then
    minetest.set_node(pos, {name = "luplights:light_dim"})
  elseif light > 2 then
    minetest.set_node(pos, {name = "luplights:light_faint"})
  end
end

local function register_light_node(name, def)
  --
  -- Register a light node
  --
  local def = def or {}
  minetest.register_node(name, {
    drawtype = "airlike",
    paramtype = "light",
    sunlight_propagates = true,
    can_dig = false,
    walkable = false,
    buildable_to = true,
    light_source = def.light_source or 4,
    groups = { not_in_creative_inventory = 1 },
    selection_box = {type = "fixed", fixed = {0, 0, 0, 0, 0, 0}},
  })
end

-------------------------------------------------------------------------------
-- Register nodes and callbaks ------------------------------------------------
-------------------------------------------------------------------------------

register_light_node("luplights:light_faint", {light_source = 4})
register_light_node("luplights:light_dim", {light_source = 8})
register_light_node("luplights:light_mid", {light_source = 12})
register_light_node("luplights:light_full", {light_source = minetest.LIGHT_MAX})

minetest.register_node("luplights:lantern", {
  description = "Lantern",
  inventory_image = "luplights_lantern.png",
  wield_image = "luplights_lantern.png",
  paramtype = "light",
  drawtype = "torchlike",
  light_source = minetest.LIGHT_MAX,
  sunlight_propagates = true,
  groups = {flammable = 1, torch = 1},
  walkable = false,
  drop = "luplights:lantern",
  tiles = {{name = "luplights_lantern.png"}},
  on_place = function()
    -- TODO: define a mesh so the lantern can be placed
  end,
})

minetest.register_craft({
  output = "luplights:lantern",
  recipe = {
    {"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
    {"default:glass", "default:torch", "default:glass"},
    {"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
  }
})

minetest.register_abm({
  action = garbage_collect_light_nodes,
  interval = 1, chance = 1, nodenames = {
    "luplights:light_faint",
    "luplights:light_dim",
    "luplights:light_mid",
    "luplights:light_full",
  },
})

minetest.register_globalstep(
  function()
    for _, player in ipairs(minetest.get_connected_players()) do
      emit_player_light(player)
    end
  end
)
