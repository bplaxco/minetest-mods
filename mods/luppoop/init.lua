local poop_interval = 600

local function player_is_connected(player)
  for _, connected in ipairs(minetest.get_connected_players()) do
    if player:get_player_name() == connected:get_player_name() then
      return true
    end
  end

  return false
end

local function poop(player)
  if player_is_connected(player) then
    minetest.sound_play("luppoop_poop", {pos = player:get_pos()}, true)
    minetest.item_drop(ItemStack("luppoop:poop"), nil, player:get_pos())
  end
end

local function queue_poop(player)
  minetest.after(math.random(poop_interval / 2) + poop_interval / 2, poop, player)
end

local function queue_poops()
  for _, player in ipairs(minetest.get_connected_players()) do
    queue_poop(player)
  end

  minetest.after(poop_interval, queue_poops)
end

local function fertalize(itemstack, user, pointed_thing)
  -- TODO
end

minetest.register_craftitem("luppoop:poop", {
  description = "Poop",
  inventory_image = "luppoop_poop.png",
  on_use = fertalize,
})

queue_poops()
