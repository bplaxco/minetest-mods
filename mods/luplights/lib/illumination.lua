-- Original author:  Piezo_
-- Original source: https://notabug.org/Piezo_/minetest-illumination/src/master/init.lua

illumination = {
    player_lights = {}
}

function illumination.register_light_point(name, def)
    minetest.register_node(name, {
      drawtype = "airlike",
      paramtype = "light",
      sunlight_propagates = true,
      can_dig = false,
      walkable = false,
      buildable_to = true,
      light_source = def.light_source or 4,
      groups = { not_in_creative_inventory = 1 },
      selection_box = { type = "fixed", fixed = {0, 0, 0, 0, 0, 0} }
    })
end

illumination.register_light_point("illumination:light_faint", {
  light_source = 4
})
illumination.register_light_point("illumination:light_dim", {
  light_source = 8
})
illumination.register_light_point("illumination:light_mid", {
  light_source = 12
})
illumination.register_light_point("illumination:light_full", {
  light_source = 15
})

-- Clean up nodes that aren't deleted
minetest.register_abm({
  interval = 1,
  chance = 1,

  nodenames = {
    "illumination:light_faint",
    "illumination:light_dim",
    "illumination:light_mid",
    "illumination:light_full"
  },

  action = function(pos)
    for _, player in ipairs(minetest.get_connected_players()) do
      if illumination.player_lights[player:get_player_name()] then
        local player_pos = illumination.player_lights[player:get_player_name()].pos
        if player_pos and vector.equals(player_pos, pos) then
          return
        end
      end
    end

    minetest.remove_node(pos)
  end
})

minetest.register_on_joinplayer(function(player)
  illumination.player_lights[player:get_player_name()] = {
    bright = 0,
    pos = vector.new(player:get_pos())
  }
end)

minetest.register_on_leaveplayer(
    function(player, _)
        local player_name = player:get_player_name()
        local remainingPlayers = {}
        for _, online in pairs(minetest.get_connected_players()) do
            if online:get_player_name() ~= player_name then
                remainingPlayers[online:get_player_name()] = illumination.player_lights[online:get_player_name()]
            end
        end
        illumination.player_lights = remainingPlayers
    end
)

local function canLight(nodeName)
    return (nodeName == "air" or nodeName == "illumination:light_faint" or nodeName == "illumination:light_dim" or
        nodeName == "illumination:light_mid" or
        nodeName == "illumination:light_full")
end

minetest.register_globalstep(
    function(dtime)
        for _, player in ipairs(minetest.get_connected_players()) do
            if illumination.player_lights[player:get_player_name()] then
                local light = 0
                if minetest.registered_nodes[player:get_wielded_item():get_name()] then
                    light = minetest.registered_nodes[player:get_wielded_item():get_name()].light_source
                end

                local pos = player:get_pos()
                pos.x = math.floor(pos.x + 0.5)
                pos.y = math.floor(pos.y + 0.5)
                pos.z = math.floor(pos.z + 0.5)
                if not canLight(minetest.get_node(pos).name) then
                    if canLight(minetest.get_node({x = pos.x, y = pos.y + 1, z = pos.z}).name) then
                        pos = {x = pos.x, y = pos.y + 1, z = pos.z}
                    elseif canLight(minetest.get_node({x = pos.x, y = pos.y + 2, z = pos.z}).name) then
                        pos = {x = pos.x, y = pos.y + 2, z = pos.z}
                    elseif canLight(minetest.get_node({x = pos.x, y = pos.y - 1, z = pos.z}).name) then
                        pos = {x = pos.x, y = pos.y - 1, z = pos.z}
                    elseif canLight(minetest.get_node({x = pos.x + 1, y = pos.y, z = pos.z}).name) then
                        pos = {x = pos.x + 1, y = pos.y, z = pos.z}
                    elseif canLight(minetest.get_node({x = pos.x, y = pos.y, z = pos.z + 1}).name) then
                        pos = {x = pos.x, y = pos.y, z = pos.z + 1}
                    elseif canLight(minetest.get_node({x = pos.x - 1, y = pos.y, z = pos.z}).name) then
                        pos = {x = pos.x - 1, y = pos.y, z = pos.z}
                    elseif canLight(minetest.get_node({x = pos.x, y = pos.y, z = pos.z - 1}).name) then
                        pos = {x = pos.x, y = pos.y, z = pos.z - 1}
                    elseif canLight(minetest.get_node({x = pos.x + 1, y = pos.y + 1, z = pos.z}).name) then
                        pos = {x = pos.x + 1, y = pos.y + 1, z = pos.z}
                    elseif canLight(minetest.get_node({x = pos.x - 1, y = pos.y + 1, z = pos.z}).name) then
                        pos = {x = pos.x - 1, y = pos.y + 1, z = pos.z}
                    elseif canLight(minetest.get_node({x = pos.x, y = pos.y + 1, z = pos.z + 1}).name) then
                        pos = {x = pos.x, y = pos.y + 1, z = pos.z + 1}
                    elseif canLight(minetest.get_node({x = pos.x, y = pos.y + 1, z = pos.z - 1}).name) then
                        pos = {x = pos.x, y = pos.y + 1, z = pos.z - 1}
                    end
                end
                local pos1 = illumination.player_lights[player:get_player_name()].pos
                local lightLast = illumination.player_lights[player:get_player_name()].bright

                illumination.player_lights[player:get_player_name()] = {}
                if canLight(minetest.get_node(pos).name) then
                    illumination.player_lights[player:get_player_name()].bright = light
                    illumination.player_lights[player:get_player_name()].pos = pos
                    local nodeName = "air"
                    if light > 2 then
                        nodeName = "illumination:light_faint"
                    end
                    if light > 7 then
                        nodeName = "illumination:light_dim"
                    end
                    if light > 10 then
                        nodeName = "illumination:light_mid"
                    end
                    if light > 13 then
                        nodeName = "illumination:light_full"
                    end
                    if nodeName then
                        minetest.set_node(pos, {name = nodeName})
                    end
                end

                if pos1 then
                    if canLight(minetest.get_node(pos1).name) then
                        if not vector.equals(pos, pos1) then
                            minetest.remove_node(pos1)
                        end
                    end
                end
            end
        end
    end
)

