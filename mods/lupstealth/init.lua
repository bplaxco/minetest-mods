local function set_alpha(name, a)
  local player = minetest.get_player_by_name(name)

  if not player then
    return false
  else
    local nametag_attributes = player:get_nametag_attributes()
    nametag_attributes.color.a = a
    player:set_nametag_attributes(nametag_attributes)
    return true
  end
end

minetest.register_chatcommand("hidename", {
  description = "Hide your nametag",
  privs = {interact = true},
  func = function(name, param)
    if set_alpha(name, 0) then
      return true, "Your nametag is hidden"
    else
      return false, "Could not hide nametag"
    end
  end
})

minetest.register_chatcommand("showname", {
  description = "Show your nametag",
  privs = {interact = true},
  func = function(name, param)
    if set_alpha(name, 255) then
      return true, "Your nametag is showing"
    else
      return false, "Could not show nametag"
    end
  end
})
