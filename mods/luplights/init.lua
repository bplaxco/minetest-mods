-- Lantern

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


-- Illumination code adapted from https://notabug.org/Piezo_/minetest-illumination/src/master/init.lua

local player_lights = {}

local function register_light_point(name, def)
  --
  -- Register a light point node
  --
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

local function inventory_light_source(player)
  if player:get_inventory():contains_item("main", "luplights:lantern") then
    return minetest.registered_nodes["luplights:lantern"].light_source
  else
    return 0
  end
end

local function on_joinplayer(player)
  --
  -- Init player light data structure
  --
  player_lights[player:get_player_name()] = {
    pos = vector.new(player:get_pos())
  }
end

local function on_leaveplayer(player)
  --
  -- Remove reference to lights
  --
  player_lights[player:get_player_name()] = nil
end

local function remove_abandoned_node(pos)
  --
  -- Clean up any left over blocks
  --
  for _, player in ipairs(minetest.get_connected_players()) do
    if player_lights[player:get_player_name()] then
      local player_pos = player_lights[player:get_player_name()].pos
      if player_pos and vector.equals(player_pos, pos) then
        return
      end
    end
  end

  minetest.remove_node(pos)
end

local function can_light(pos)
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
    if player_lights[player:get_player_name()] then
      local pos = player:get_pos()

      pos.x = math.floor(pos.x + 0.5)
      pos.y = math.floor(pos.y + 0.5)
      pos.z = math.floor(pos.z + 0.5)

      if not can_light(pos) then
        if can_light({x = pos.x, y = pos.y + 1, z = pos.z}) then
          pos = {x = pos.x, y = pos.y + 1, z = pos.z}
        elseif can_light({x = pos.x, y = pos.y + 2, z = pos.z}) then
          pos = {x = pos.x, y = pos.y + 2, z = pos.z}
        elseif can_light({x = pos.x, y = pos.y - 1, z = pos.z}) then
          pos = {x = pos.x, y = pos.y - 1, z = pos.z}
        elseif can_light({x = pos.x + 1, y = pos.y, z = pos.z}) then
          pos = {x = pos.x + 1, y = pos.y, z = pos.z}
        elseif can_light({x = pos.x, y = pos.y, z = pos.z + 1}) then
          pos = {x = pos.x, y = pos.y, z = pos.z + 1}
        elseif can_light({x = pos.x - 1, y = pos.y, z = pos.z}) then
          pos = {x = pos.x - 1, y = pos.y, z = pos.z}
        elseif can_light({x = pos.x, y = pos.y, z = pos.z - 1}) then
          pos = {x = pos.x, y = pos.y, z = pos.z - 1}
        elseif can_light({x = pos.x + 1, y = pos.y + 1, z = pos.z}) then
          pos = {x = pos.x + 1, y = pos.y + 1, z = pos.z}
        elseif can_light({x = pos.x - 1, y = pos.y + 1, z = pos.z}) then
          pos = {x = pos.x - 1, y = pos.y + 1, z = pos.z}
        elseif can_light({x = pos.x, y = pos.y + 1, z = pos.z + 1}) then
          pos = {x = pos.x, y = pos.y + 1, z = pos.z + 1}
        elseif can_light({x = pos.x, y = pos.y + 1, z = pos.z - 1}) then
          pos = {x = pos.x, y = pos.y + 1, z = pos.z - 1}
        end
      end

      player_lights[player:get_player_name()] = {}

      if can_light(pos) then
        player_lights[player:get_player_name()].pos = pos

        local light = inventory_light_source(player)
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

      local player_pos = player_lights[player:get_player_name()].pos

      if player_pos and can_light(player_pos) and not vector.equals(pos, player_pos) then
        minetest.remove_node(player_pos)
      end
    end
  end
end

register_light_point("luplights:light_faint", {light_source = 4})
register_light_point("luplights:light_dim", {light_source = 8})
register_light_point("luplights:light_mid", {light_source = 12})
register_light_point("luplights:light_full", {light_source = 15})

minetest.register_on_joinplayer(on_joinplayer)
minetest.register_on_leaveplayer(on_leaveplayer)
minetest.register_globalstep(globalstep)
minetest.register_abm({
  interval = 1, chance = 1, action = remove_abandoned_node, nodenames = {
    "luplights:light_faint",
    "luplights:light_dim",
    "luplights:light_mid",
    "luplights:light_full",
  },
})


