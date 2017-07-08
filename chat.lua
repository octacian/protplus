-- protplus/chat.lua

-- [chatcommand] /protpoint
minetest.register_chatcommand("protpoint", {
	description = "Set/unset protection points",
	params = "[1 | 2 | umk | unmark]",
	privs = {protplus = true},
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		local pos = vector.round(player:get_pos())
		local stringpos = minetest.pos_to_string(pos)
		local ok, msg = false, "Invalid usage (see /help protpoint)"

		if param == "1" then
			if protplus:mark(name, pos) then
				ok, msg = true, "Position 1 set to "..stringpos
			else
				ok, msg = false, "Could not set position 1"
			end
		elseif param == "2" then
			if protplus:mark(name, nil, pos) then
				ok, msg = true, "Position 2 set to "..stringpos
			else
				ok, msg = false, "Could not set position 2"
			end
		elseif param == "umk" or param == "unmark" then
			if protplus:unmark(name, true, true, true) then
				ok, msg = true, "Unmarked region"
			else
				ok, msg = false, "Nothing to unmark"
			end
		end

		if protplus.mpos1[name] and protplus.mpos2[name] then
			protplus:mark(name, protplus.mpos1[name], protplus.mpos2[name])
		end

		return ok, msg
	end,
})

-- [chatcommand] /protect
minetest.register_chatcommand("protect", {
	description = "Protect selected region",
	params = "[<region name>]",
	privs = {protplus = true},
	func = function(name, param)
		if param and param ~= "" then
			local pos1, pos2 = protplus.mpos1[name], protplus.mpos2[name]
			if pos1 and pos2 then
				if protplus:can_protect(name, pos1, pos2) then
					local id = protplus:add(name, param, pos1, pos2)
					if id then
						return true, "Protected region as "..param.." (id: "..
								tostring(id)..")"
					end
				else
					return false, "Selected region overlaps with another region which "..
							"you do not have permission to access"
				end
			else
				return false, "No region selected"
			end
		end
	end,
})

-- [chatcommand] /protlist
minetest.register_chatcommand("protlist", {
	description = "List regions protected by you or another player",
	params = "[<player name>]",
	privs = {protplus = true},
	func = function(name, param)
		local player = name
		if param and param ~= "" then
			player = param
		end

		local owned, member = protplus:get_player_regions(player, true)
		if not owned and not member then
			return false, player.." does not own and is not a member of any regions"
		else
			local ret = ""
			if owned then
				ret = ret..player.." owns: "..table.concat(owned, ", ")
			end
			if member then
				if ret ~= "" then
					ret = ret.."\n"
				end
				ret = ret..player.." is a member of: "..table.concat(member, ", ")
			end

			return true, ret
		end
	end,
})

-- [chatcommand] /protdel
minetest.register_chatcommand("protdel", {
	description = "Remove protection from a region",
	params = "[<region id>]",
	privs = {protplus = true},
	func = function(name, param)
		local id = tonumber(param)
		if id then
			if protplus:can_modify(id, name) then
				if protplus:remove(id) then
					return true, "Removed protection from region "..tostring(id)
				else
					return false, "Could not remove protection from region"
				end
			else
				return false, "You do not have permission to delete this region"
			end
		else
			return false, "Invalid parameters (see /help protdel)"
		end
	end,
})

-- [chatcommand] /protrename
minetest.register_chatcommand("protrename", {
	description = "Rename protected region",
	params = "[<region id>] [<new region name>]",
	privs = {protplus = true},
	func = function(name, params)
		local split = params:split(" ")
		local id, rname = tonumber(split[1]), split[2]
		if id and rname and protplus:get_region(id) then
			if protplus:can_modify(id, name) then
				if protplus:rename(id, rname) then
					return true, "Renamed region "..tostring(id).." to "..rname
				else
					return false, "Could not rename region"
				end
			else
				return false, "You do not have permission to rename this region"
			end
		else
			return false, "Invalid parameters (see /help protrename)"
		end
	end,
})

-- [chatcommand] /protmove
minetest.register_chatcommand("protmove", {
	description = "Move/resize a protected region",
	params = "[<region id>] [start | cancel | complete]",
	privs = {protplus = true},
	func = function(name, params)
		local split = params:split(" ")
		local id, operation = tonumber(split[1]), split[2]
		local region = protplus:get_region(id)
		if id and region and operation then
			if protplus:can_modify(id, name) then
				if operation == "start" then
					if protplus:mark(name, region.pos1) and
							protplus:mark(name, nil, region.pos2) and
							protplus:mark(name, region.pos1, region.pos2) then
						return true, "Move region (marked) with /protpoint (save with "..
								"/protmove "..tostring(id).." complete)"
					else
						return false, "Could not start region move"
					end
				elseif operation == "cancel" then
					if protplus:unmark(name, true, true, true) then
						return true, "Cancelled region move"
					else
						return false, "Nothing to cancel"
					end
				elseif operation == "complete" then
					local pos1, pos2 = protplus.mpos1[name], protplus.mpos2[name]
					if pos1 and pos2 then
						if protplus:can_protect(name, pos1, pos2) then
							if protplus:move(id, pos1, pos2) then
								return true, "Moved region "..tostring(id).." (unmark with "..
										"/protpoint umk or /protpoint unmark)"
							else
								return false, "Could not move region"
							end
						else
							return false, "Selected region overlaps with another region which "..
									"you do not have permission to access"
						end
					else
						return false, "New region not marked"
					end
				end
			else
				return false, "You do not have permission to modify this region"
			end
		else
			return false, "Invalid parameters (see /help protmove)"
		end
	end,
})

-- [chatcommand] /protshow
minetest.register_chatcommand("protshow", {
	description = "Highlight protected region",
	params = "[<region id>]",
	privs = {protplus = true},
	func = function(name, param)
		local id = tonumber(param)
		if id and protplus:get_region(id) then
			if protplus:can_modify(id, name) then
				local region = protplus:get_region(id)
				if region then
					if protplus:mark(name, region.pos1, region.pos2) then
						return true, "Marked region "..region.name.." ["..tostring(id)..
								"] (unmark with /protpoint umk or /protpoint unmark)"
					else
						return false, "Could not mark region"
					end
				else
					return false, "Invalid region"
				end
			else
				return false, "You do not have permission to view this region"
			end
		else
			return false, "Invalid parameters (see /help protshow)"
		end
	end,
})

-- [chatcommand] /protowner
minetest.register_chatcommand("protowner", {
	description = "Get or change the owner of a region",
	params = "[<region id>] [<new owner>]",
	privs = {protplus = true},
	func = function(name, params)
		local split = params:split(" ")
		local id, owner = tonumber(split[1]), split[2]
		if id and owner then
			if protplus:can_modify(id, name) then
				if protplus:set_owner(id, owner) then
					return true, "Changed owner of region "..tostring(id).." to "..owner
				else
					return false, "Could not change owner of region"
				end
			else
				return false, "You do not have permission to modify this region"
			end
		elseif id and not owner then
			local region = protplus:get_region(id)
			if region then
				return true, region.owner.." owns region "..tostring(id)
			else
				return false, "Could not identify region owner"
			end
		else
			return false, "Invalid parameters (see /help protowner)"
		end
	end,
})

-- [chatcommand] /protmember
minetest.register_chatcommand("protmember", {
	description = "Get or change the member list of a region",
	params = "[<region id>] [add | del | list] (<player name>)",
	privs = {protplus = true},
	func = function(name, params)
		local invalid_msg = "Invalid parameters (see /help protmember)"
		local split = params:split(" ")
		local id, operation, mname = tonumber(split[1]), split[2], split[3]
		local region = protplus:get_region(id)
		if id and region then
			if protplus:can_modify(id, name) then
				if operation == "list" then
					local members = protplus:get_members_by_id(id)
					if members then
						return false, "Members of region "..tostring(id)..": "..
								table.concat(members, ", ")
					else
						return false, "This region has no members"
					end
				elseif operation == "add" then
					if mname then
						if protplus:add_member(id, mname) then
							return true, "Added "..mname.." as a member of region "..tostring(id)
						else
							return false, "Could not add member to region"
						end
					else
						return false, invalid_msg
					end
				elseif operation == "del" then
					if mname then
						if protplus:remove_member(id, mname) then
							return true, "Removed member "..mname.." from region "..tostring(id)
						else
							return false, "Could not remove member to region"
						end
					else
						return false, invalid_msg
					end
				else
					return false, invalid_msg
				end
			else
				return false, "You do not have permission to access or modify member "..
						"data for this region"
			end
		else
			return false, invalid_msg
		end
	end,
})

-- [chatcommand] /protflags
minetest.register_chatcommand("protflags", {
	description = "Get/set flags for a protected region",
	params = "[<region id> | help] [get | list | set | del | <flag name>] (<flag name>) (<flag value>)",
	privs = {protplus = true},
	func = function(name, params)
		local split = params:split(" ")
		local invalid_msg = "Invalid parameters (see /help protflags)"
		local id, operation, flag, value = tonumber(split[1]), split[2], split[3], split[4]

		if id and protplus:get_region(id) and operation then
			local flags = protplus:get_flags(id)
			if operation == "get" and flag then
				if flags[flag] then
					return true, "Flag \""..flag.."\" is set to "..tostring(flags[flag])
				else
					return false, "Invalid flag \""..flag.."\""
				end
			elseif operation == "list" then
				flags = protplus:get_flags(id, true)
				if flags then
					return true, "Flags: "..table.concat(flags, ", ")
				else
					return false, "No flags set"
				end
			elseif operation == "set" and flag and value then
				if value == "true" then
					value = true
				elseif value == "false" then
					value = false
				end

				local new_flags = {}
				new_flags[flag] = value
				if protplus:set_flags(id, new_flags) then
					return true, "Set flag \""..flag.."\" to \""..tostring(value).."\""
				else
					return false, "Could not update flag"
				end
			elseif operation == "del" and flag then
				if flags[flag] ~= nil then
					flags[flag] = nil
					if protplus:set_flags(id, flags) then
						return true, "Deleted flag \""..flag.."\""
					else
						return false, "Could not delete flag"
					end
				else
					return false, "Invalid flag \""..flag.."\""
				end
			else
				return false, invalid_msg
			end
		elseif split[1] and split[1] == "help" then
			if split[2] == "damage" then
				return true, "damage (type: boolean) - toggle damage in region"
			elseif split[2] == "hud" then
				return true, "hud (type: boolean) - toggle HUD in region"
			else
				return true, "Valid Flags: damage (boolean), hud (boolean)"
			end
		else
			return false, invalid_msg
		end
	end,
})
