-- protplus/wand.lua

-- [craftitem] Wand
minetest.register_craftitem("protplus:wand", {
	description = "ProtPlus Wand\n"..minetest.colorize("grey", "Left-click to "..
			"set 1st position\nRight-click to set 2nd\nShift+Right-click to unmark"),
	inventory_image = "protplus_wand.png",
	stack_max = 1,
	liquids_pointable = true,

	-- Set position 1
	on_use = function(itemstack, player, pointed_thing)
		if player and pointed_thing and pointed_thing.type == "node" then
			local name = player:get_player_name()
			protplus:mark(name, pointed_thing.under)

			if protplus.mpos1[name] and protplus.mpos2[name] then
				protplus:mark(name, protplus.mpos1[name], protplus.mpos2[name])
			end
		end
	end,

	-- Set position 2 or unmark
	on_place = function(itemstack, player, pointed_thing)
		if player and pointed_thing and pointed_thing.type == "node" then
			local ctrl = player:get_player_control()
			local name = player:get_player_name()
			if ctrl.sneak then
				protplus:unmark(name, true, true, true)
			else
				protplus:mark(name, nil, pointed_thing.under)

				if protplus.mpos1[name] and protplus.mpos2[name] then
					protplus:mark(name, protplus.mpos1[name], protplus.mpos2[name])
				end
			end
		end
	end,
})
