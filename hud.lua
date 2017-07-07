-- protplus/hud.lua

local huds = {}

-- [event] Check for regions on globalstep
minetest.register_globalstep(function(dtime)
	for _, player in pairs(minetest.get_connected_players()) do
		local pos     = vector.round(player:get_pos())
		local name    = player:get_player_name()
		local regions = protplus:is_protected(pos) or {}

		local list    = {}
		for id, r in pairs(regions) do
			if r.flags and r.flags.hud == true then
				list[#list + 1] = r.name.." ["..tostring(id).."] ("..r.owner..")"
			end
		end

		local regionString = ""
		if #list > 0 then
			regionString = "Regions:".."\n"..
				table.concat(list, "\n")
		end

		if huds[name] then
			player:hud_change(huds[name], "text", regionString)
		else
			huds[name] = player:hud_add({
				hud_elem_type = "text",
				name = "Regions",
				number = 0xFFFFFF,
				position = {x = 0, y = 1},
				offset = {x = 8, y = -8},
				text = regionString,
				scale = {x = 200, y = 60},
				alignment = {x = 1, y = -1},
			})
		end
	end
end)
