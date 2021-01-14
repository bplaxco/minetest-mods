-------------------------------------------------------------------------------
-- Define the luplights API ---------------------------------------------------
-------------------------------------------------------------------------------

luplights = {
  player_lights = {},
}

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

function luplights.inventory_light_source(player)
  --
  -- Returns the light source value of what's in the player's inventory
  --
  if player:get_inventory():contains_item("main", "luplights:lantern") then
    return minetest.registered_nodes["luplights:lantern"].light_source
  else
    return 0
  end
end

function luplights.init_player_light(player)
  --
  -- Init player light data structure
  --
  luplights.player_lights[player:get_player_name()] = {
    pos = vector.new(player:get_pos())
  }
end

function luplights.remove_player_light(to_remove)
  --
  -- Remove reference to lights
  --
  local new_player_lights = {}
  local to_remove_name = to_remove:get_player_name()

  for _, player in pairs(minetest.get_connected_players()) do
    local name = player:get_player_name()
    if name ~= to_remove_name then
      new_player_lights[online_name] = luplights.player_lights[online_name]
    end
  end

  luplights.player_lights = new_player_lights
end

function luplights.light_pos(player)
  --
  -- Returns the postion of a player light if it exists else nil
  --
  light = luplights.player_lights[player:get_player_name()]

  if light then
    return light.pos
  else
    return nil
  end
end


function luplights.remove_abandoned_node(pos)
  --
  -- Clean up any left over blocks
  --
  for _, player in ipairs(minetest.get_connected_players()) do
    if vector.equals(luplights.light_pos(player), pos) then
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

local function globalstep(dtime)
  --
  -- Light the area
  --
  for _, player in ipairs(minetest.get_connected_players()) do
    if luplights.player_lights[player:get_player_name()] then
      local pos = player:get_pos()

      pos.x = math.floor(pos.x + 0.5)
      pos.y = math.floor(pos.y + 0.5)
      pos.z = math.floor(pos.z + 0.5)

      if not luplights.lightable(pos) then
        if luplights.lightable({x = pos.x, y = pos.y + 1, z = pos.z}) then
          pos = {x = pos.x, y = pos.y + 1, z = pos.z}
        elseif luplights.lightable({x = pos.x, y = pos.y + 2, z = pos.z}) then
          pos = {x = pos.x, y = pos.y + 2, z = pos.z}
        elseif luplights.lightable({x = pos.x, y = pos.y - 1, z = pos.z}) then
          pos = {x = pos.x, y = pos.y - 1, z = pos.z}
        elseif luplights.lightable({x = pos.x + 1, y = pos.y, z = pos.z}) then
          pos = {x = pos.x + 1, y = pos.y, z = pos.z}
        elseif luplights.lightable({x = pos.x, y = pos.y, z = pos.z + 1}) then
          pos = {x = pos.x, y = pos.y, z = pos.z + 1}
        elseif luplights.lightable({x = pos.x - 1, y = pos.y, z = pos.z}) then
          pos = {x = pos.x - 1, y = pos.y, z = pos.z}
        elseif luplights.lightable({x = pos.x, y = pos.y, z = pos.z - 1}) then
          pos = {x = pos.x, y = pos.y, z = pos.z - 1}
        elseif luplights.lightable({x = pos.x + 1, y = pos.y + 1, z = pos.z}) then
          pos = {x = pos.x + 1, y = pos.y + 1, z = pos.z}
        elseif luplights.lightable({x = pos.x - 1, y = pos.y + 1, z = pos.z}) then
          pos = {x = pos.x - 1, y = pos.y + 1, z = pos.z}
        elseif luplights.lightable({x = pos.x, y = pos.y + 1, z = pos.z + 1}) then
          pos = {x = pos.x, y = pos.y + 1, z = pos.z + 1}
        elseif luplights.lightable({x = pos.x, y = pos.y + 1, z = pos.z - 1}) then
          pos = {x = pos.x, y = pos.y + 1, z = pos.z - 1}
        end
      end

      luplights.player_lights[player:get_player_name()] = {}

      if luplights.lightable(pos) then
        luplights.player_lights[player:get_player_name()].pos = pos

        local light = luplights.inventory_light_source(player)
        local wielded_node = minetest.registered_nodes[player:get_wielded_item():get_name()]

        if wielded_node and wielded_node.light_source > light then
          light = wielded_node.light_source
        end

        if light > 13 then
          minetest.set_node(pos, {name = "luplights:light_full"})
        elseif light > 10 then
          minetest.set_node(pos, {name = "luplights:light_mid"})
        elseif light > 7 then
          minetest.set_node(pos, {name = "luplights:light_dim"})
        elseif light > 2 then
          minetest.set_node(pos, {name = "luplights:light_faint"})
        else
          minetest.set_node(pos, {name = "air"})
        end
      end

      local player_pos = luplights.player_lights[player:get_player_name()].pos

      if player_pos and luplights.lightable(player_pos) and not vector.equals(pos, player_pos) then
        minetest.remove_node(player_pos)
      end
    end
  end
end


-------------------------------------------------------------------------------
-- Register nodes and callbaks ------------------------------------------------
-------------------------------------------------------------------------------

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
  on_place = function(_, _, _)
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

luplights.register_light_point("luplights:light_faint", {light_source = 4})
luplights.register_light_point("luplights:light_dim", {light_source = 8})
luplights.register_light_point("luplights:light_mid", {light_source = 12})
luplights.register_light_point("luplights:light_full", {light_source = 15})

minetest.register_on_joinplayer(luplights.init_player_light)
minetest.register_on_leaveplayer(luplights.remove_player_light)
minetest.register_globalstep(globalstep)
minetest.register_abm({
  interval = 1, chance = 1, action = luplights.remove_abandoned_node, nodenames = {
    "luplights:light_faint",
    "luplights:light_dim",
    "luplights:light_mid",
    "luplights:light_full",
  },
})
