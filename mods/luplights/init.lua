-------------------------------------------------------------------------------
-- Define the luplights API ---------------------------------------------------
-------------------------------------------------------------------------------

luplights = {}

function luplights.register_light_point(name, def)
  --
  -- Register a light point node
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

function luplights.inventory_light(player)
  --
  -- Returns the light source value of what's in the player's inventory
  --
  if player:get_inventory():contains_item("main", "luplights:lantern") then
    return minetest.registered_nodes["luplights:lantern"].light_source
  else
    return 0
  end
end

function luplights.wielded_light(player)
  local wielded_node = minetest.registered_nodes[player:get_wielded_item():get_name()]

  if wielded_node and  wielded_node.light_source then
    return wielded_node.light_source
  else
    return 0
  end
end

function luplights.garbage_collect_light_points(pos)
  --
  -- Clean blocks away from the player
  --
  for _, player in ipairs(minetest.get_connected_players()) do
    local light_pos = luplights.lightable_pos(player)
    if light_pos and vector.equals(light_pos, pos) then
      return
    end
  end

  minetest.remove_node(pos)
end

function luplights.lightable(pos)
  --
  -- Can a light block be placed here
  --
  name = minetest.get_node(pos).name

  return (
    name == "air" or
    name == "luplights:light_faint" or name == "luplights:light_dim" or
    name == "luplights:light_mid" or name == "luplights:light_full"
  )
end

function luplights.player_light(player)
  local pos = luplights.lightable_pos(player)

  if not pos then
    return 0, nil
  end

  local inventory = luplights.inventory_light(player)

  if inventory == minetest.LIGHT_MAX then
    return inventory, pos
  end

  local wielded = luplights.wielded_light(player)

  if wielded > inventory then
    return wielded, pos
  else
    return inventory, pos
  end
end

function luplights.lightable_pos(player)
  --
  -- Return a position that could be lightable or nil
  --

  local pos = player:get_pos()
  pos.x = math.floor(pos.x + 0.5)
  pos.y = math.floor(pos.y + 0.5)
  pos.z = math.floor(pos.z + 0.5)

  if luplights.lightable(pos) then
    return pos
  elseif luplights.lightable({x = pos.x, y = pos.y + 1, z = pos.z}) then
    return {x = pos.x, y = pos.y + 1, z = pos.z}
  elseif luplights.lightable({x = pos.x, y = pos.y + 2, z = pos.z}) then
    return {x = pos.x, y = pos.y + 2, z = pos.z}
  elseif luplights.lightable({x = pos.x, y = pos.y - 1, z = pos.z}) then
    return {x = pos.x, y = pos.y - 1, z = pos.z}
  elseif luplights.lightable({x = pos.x + 1, y = pos.y, z = pos.z}) then
    return {x = pos.x + 1, y = pos.y, z = pos.z}
  elseif luplights.lightable({x = pos.x, y = pos.y, z = pos.z + 1}) then
    return {x = pos.x, y = pos.y, z = pos.z + 1}
  elseif luplights.lightable({x = pos.x - 1, y = pos.y, z = pos.z}) then
    return {x = pos.x - 1, y = pos.y, z = pos.z}
  elseif luplights.lightable({x = pos.x, y = pos.y, z = pos.z - 1}) then
    return {x = pos.x, y = pos.y, z = pos.z - 1}
  elseif luplights.lightable({x = pos.x + 1, y = pos.y + 1, z = pos.z}) then
    return {x = pos.x + 1, y = pos.y + 1, z = pos.z}
  elseif luplights.lightable({x = pos.x - 1, y = pos.y + 1, z = pos.z}) then
    return {x = pos.x - 1, y = pos.y + 1, z = pos.z}
  elseif luplights.lightable({x = pos.x, y = pos.y + 1, z = pos.z + 1}) then
    return {x = pos.x, y = pos.y + 1, z = pos.z + 1}
  elseif luplights.lightable({x = pos.x, y = pos.y + 1, z = pos.z - 1}) then
    return {x = pos.x, y = pos.y + 1, z = pos.z - 1}
  else
    return nil
  end
end

function luplights.emit_player_light()
  --
  -- Light the area
  --
  for _, player in ipairs(minetest.get_connected_players()) do
    local light, pos = luplights.player_light(player)

    if light == 0 then
      -- noop
    elseif light > 13 then
      minetest.set_node(pos, {name = "luplights:light_full"})
    elseif light > 10 then
      minetest.set_node(pos, {name = "luplights:light_mid"})
    elseif light > 7 then
      minetest.set_node(pos, {name = "luplights:light_dim"})
    elseif light > 2 then
      minetest.set_node(pos, {name = "luplights:light_faint"})
    end
  end
end


-------------------------------------------------------------------------------
-- Register nodes and callbaks ------------------------------------------------
-------------------------------------------------------------------------------

luplights.register_light_point("luplights:light_faint", {light_source = 4})
luplights.register_light_point("luplights:light_dim", {light_source = 8})
luplights.register_light_point("luplights:light_mid", {light_source = 12})
luplights.register_light_point("luplights:light_full", {light_source = minetest.LIGHT_MAX})

minetest.register_globalstep(luplights.emit_player_light)

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
  action = luplights.garbage_collect_light_points,
  interval = 1, chance = 1, nodenames = {
    "luplights:light_faint",
    "luplights:light_dim",
    "luplights:light_mid",
    "luplights:light_full",
  },
})
