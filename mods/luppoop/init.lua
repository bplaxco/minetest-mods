local poop_interval = 600
local poop_to_fertalize = 3

local function player_is_connected(player)
  --
  -- Check if player is connected
  --
  for _, connected in ipairs(minetest.get_connected_players()) do
    if player:get_player_name() == connected:get_player_name() then
      return true
    end
  end

  return false
end

local function poop(player)
  --
  -- Drop poop
  --
  if player_is_connected(player) then
    minetest.sound_play("luppoop_poop", {pos = player:get_pos()}, true)
    minetest.item_drop(ItemStack("luppoop:poop"), nil, player:get_pos())
  end
end

local function queue_poop(player)
  --
  -- Queue up random poop for player
  --
  minetest.after(math.random(poop_interval), poop, player)
end

local function queue_poops()
  --
  -- Queue up poops for all connected players
  --
  for _, player in ipairs(minetest.get_connected_players()) do
    queue_poop(player)
  end

  minetest.after(poop_interval, queue_poops)
end

local function fertalize(itemstack, user, pointed_thing)
  --
  -- Use $poop_to_fertalize poop to fertalize something
  --
  -- TODO: support more node types
  --
  if not pointed_thing or itemstack:get_count() < poop_to_fertalize then
    return
  end

  if pointed_thing.type == "node" then
    local pos = pointed_thing.under
    local node = minetest.get_node(pos)
    local is_sapling = node and node.name:match("default:.*sapling")

    if is_sapling and default.can_grow(pos) then
      itemstack:take_item(poop_to_fertalize)
      default.grow_sapling(pos)
    end
  end

  return itemstack
end

minetest.register_craftitem("luppoop:poop", {
  description = "Poop",
  inventory_image = "luppoop_poop.png",
  on_use = fertalize,
})

queue_poops()
