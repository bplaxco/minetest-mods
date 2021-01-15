player = {
  inventory = {
    main = {},
  }
}

function player.get_inventory()
  return {
    contains_item = function(_, list, name)
      return player.inventory[list][name]
    end,
  }
end

function player:get_player_name()
  return player.name
end

function player:get_pos()
  return player.pos
end

function player:get_wielded_item()
  return player.inventory.wielded
end
