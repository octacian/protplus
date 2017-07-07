-- protplus/init.lua

protplus = {}

local path       = minetest.get_worldpath().."/protplus.mt"
local modpath    = minetest.get_modpath("protplus")
protplus.markers = {}
protplus.mark1   = {}
protplus.mark2   = {}
protplus.mpos1   = {}
protplus.mpos2   = {}

---
--- Functions
---

--- Copies and modifies positions `pos1` and `pos2` so that each component of
-- `pos1` is less than or equal to the corresponding component of `pos2`.
-- Returns the new positions.
function protplus:sort_pos(pos1, pos2)
	if not pos1 or not pos2 then
		return
	end

	if pos1.x > pos2.x then
		pos2.x, pos1.x = pos1.x, pos2.x
	end
	if pos1.y > pos2.y then
		pos2.y, pos1.y = pos1.y, pos2.y
	end
	if pos1.z > pos2.z then
		pos2.z, pos1.z = pos1.z, pos2.z
	end
	return pos1, pos2
end

-- [function] Load
function protplus:load()
	local res = io.open(path, "r")
	if res then
		self.regions = minetest.deserialize(res:read("*a"))
		if type(self.regions) ~= "table" then
			self.regions = {}
		end

		res:close()
	end
end

-- [function] Save
function protplus:save()
	local res = io.open(path, "w")
	if res then
		res:write(minetest.serialize(self.regions))
		res:close()
	end
end

-- [function] Get all regions
function protplus:get_regions()
	return self.regions
end

-- [function] Get region by ID
function protplus:get_region(id)
	if self.regions[id] then
		return self.regions[id]
	end
end

-- [function] Is protected
function protplus:is_protected(pos)
	local retval = {}

	local px, py, pz = pos.x, pos.y, pos.z
	for id, r in pairs(self.regions) do
		local ap1, ap2 = r.pos1, r.pos2
		if (px >= ap1.x and px <= ap2.x) and
				(py >= ap1.y and py <= ap2.y) and
				(pz >= ap1.z and pz <= ap2.z) then
			retval[id] = r
		end
	end

	if #retval ~= 0 then
		return retval
	end
end

-- [function] Get owner by id
function protplus:get_owner_by_id(id)
	if self.regions[id] then
		return self.regions[id].owner
	end
end

-- [function] Get members by id
function protplus:get_members_by_id(id)
	if self.regions[id] then
		if #self.regions[id].members > 0 then
			return self.regions[id].members
		end
	end
end

-- [function] Get owners by pos
function protplus:get_owners(pos)
	local added   = {}
	local owners  = {}
	local regions = protplus:is_protected(pos)
	if regions then
		for id, r in pairs(regions) do
			local owner = protplus:get_owner_by_id(id)
			if not added[owner] then
				owners[#owners + 1] = owner
				added[owner] = true
			end
		end
	end

	if #owners > 0 then
		return owners
	end
end

-- [function] Get members by pos
function protplus:get_members(pos)
	local members = {}
	local regions = protplus:is_protected(pos)
	if regions then
		for id, r in pairs(regions) do
			local amembers = protplus:get_members_by_id(id)
			if amembers then
				for __, m in pairs(amembers) do
					members[#members + 1] = m
				end
			end
		end
	end

	if #members > 0 then
		return members
	end
end

-- [function] Is owner
function protplus:is_owner(id, name)
	if protplus:get_owner_by_id(id) == name then
		return true
	end
end

-- [function] Is member
function protplus:is_member(id, name)
	local members = protplus:get_members_by_id(id)
	if members then
		for _, member in pairs(members) do
			if member == name then
				return true
			end
		end
	end
end

-- [function] Is admin
function protplus:is_admin(name)
	if minetest.check_player_privs(name, "protplus_bypass") or
			minetest.settings:get("name") == name then
		return true
	end
end

-- [function] Can modify region
function protplus:can_modify(id, name)
	if self.regions[id] then
		if protplus:is_owner(id, name) or protplus:is_member(id, name) or
				protplus:is_admin(name) then
			return true
		end
	end
end

-- [function] Can interact
function protplus:can_interact(pos, name)
	if type(name) == "userdata" then
		name = name:get_player_name()
	end

	if protplus:is_admin(name) then
		return true
	end

	local regions = protplus:is_protected(pos)
	if regions then
		for id, r in pairs(regions) do
			if protplus:can_modify(id, name) then
				return true
			end
		end
	else
		return true
	end
end

-- [function] Get regions by player
function protplus:get_player_regions(name, format)
	local owned  = {}
	local member = {}
	for id, r in pairs(self.regions) do
		if protplus:is_owner(id, name) then
			if format then
				owned[#owned + 1] = r.name.." ["..tostring(id).."]"
			else
				owned[id] = r
			end
		elseif protplus:is_member(id, name) then
			if format then
				member[#member + 1] = r.name.." ["..tostring(id).."]"
			else
				member[id] = r
			end
		end
	end

	if #owned == 0 then
		owned = nil
	end
	if #member == 0 then
		member = nil
	end

	return owned, member
end

-- [function] Get intersecting
function protplus:get_intersect(pos1, pos2)
	pos1, pos2 = protplus:sort_pos(pos1, pos2)
	local res = {}
	local p1x, p1y, p1z = pos1.x, pos1.y, pos1.z
	local p2x, p2y, p2z = pos2.x, pos2.y, pos2.z
	for id, r in pairs(self.regions) do
		local ap1, ap2 = r.pos1, r.pos2
		if (ap1.x <= p2x and ap2.x >= p1x) and
				(ap1.y <= p2y and ap2.y >= p1y) and
				(ap1.z <= p2z and ap2.z >= p1z) then
			res[id] = r
		end
	end

	if #res > 0 then
		return res
	end
end

-- [function] Can protect (checks for overlapping areas)
function protplus:can_protect(name, pos1, pos2)
	if protplus:is_admin(name) then
		return true
	end

	local regions = protplus:get_intersect(pos1, pos2)
	if regions then
		for id, r in pairs(regions) do
			if not protplus:is_owner(id, name) and not protplus:is_member(id, name) then
				return false
			end
		end
	end

	return true
end

-- [function] Get flags
function protplus:get_flags(id, format)
	if self.regions[id] then
		if format then
			local ret   = {}
			local flags = self.regions[id].flags or {}
			for name, f in pairs(flags) do
				ret[#ret + 1] = name.." = "..tostring(f)
			end

			if #ret > 0 then
				return ret
			end
		else
			return self.regions[id].flags or {}
		end
	end
end

-- [function] Set flags
function protplus:set_flags(id, new_flags)
	if self.regions[id] then
		local flags = self.regions[id].flags or {}
		for _, f in pairs(new_flags) do
			flags[_] = f
		end
		self.regions[id].flags = flags
		return true
	end
end

-- [function] Protect region
function protplus:add(owner, name, pos1, pos2)
	local id = #self.regions + 1
	self.regions[id] = {
		name = name,
		owner = owner,
		members = {},
		flags = {},
		pos1 = pos1,
		pos2 = pos2,
	}

	return id
end

-- [function] Move region
function protplus:move(id, pos1, pos2)
	if pos1 and pos2 and self.regions[id] then
		self.regions[id].pos1 = pos1
		self.regions[id].pos2 = pos2
		return true
	end
end

-- [function] Rename region
function protplus:rename(id, name)
	if self.regions[id] then
		self.regions[id].name = name
		return true
	end
end

-- [function] Remove protection from region
function protplus:remove(id)
	if self.regions[id] then
		self.regions[id] = nil
		return true
	end
end

-- [function] Set owner
function protplus:set_owner(id, owner)
	if self.regions[id] then
		self.regions[id].owner = owner
		return true
	end
end

-- [function] Add member
function protplus:add_member(id, member)
	if self.regions[id] then
		self.regions[id].members[#self.regions[id].members] = member
		return true
	end
end

-- [function] Remove member
function protplus:remove_member(id, member)
	if self.regions[id] then
		local members = self.regions[id].members
		for _, i in pairs(members) do
			if i == member then
				members[_] = nil
				return true
			end
		end
	end
end

-- [function] Mark region
function protplus:mark(name, pos1, pos2)
	if pos1 and pos2 then
		protplus:unmark(name, nil, nil, true)
		pos1, pos2 = protplus:sort_pos(pos1, pos2)

		local thickness = 0.2
		local sizex, sizey, sizez = (1 + pos2.x - pos1.x) / 2, (1 + pos2.y - pos1.y) / 2, (1 + pos2.z - pos1.z) / 2
		local m = {}

		--XY plane markers
		for _, z in ipairs({pos1.z - 0.5, pos2.z + 0.5}) do
			local marker = minetest.add_entity({x=pos1.x + sizex - 0.5, y=pos1.y + sizey - 0.5, z=z}, "protplus:display")
			if marker ~= nil then
				marker:set_properties({
					visual_size={x=sizex * 2, y=sizey * 2},
					collisionbox = {-sizex, -sizey, -thickness, sizex, sizey, thickness},
				})
				marker:get_luaentity().player_name = name
				table.insert(m, marker)
			end
		end

		--YZ plane markers
		for _, x in ipairs({pos1.x - 0.5, pos2.x + 0.5}) do
			local marker = minetest.add_entity({x=x, y=pos1.y + sizey - 0.5, z=pos1.z + sizez - 0.5}, "protplus:display")
			if marker ~= nil then
				marker:set_properties({
					visual_size={x=sizez * 2, y=sizey * 2},
					collisionbox = {-thickness, -sizey, -sizez, thickness, sizey, sizez},
				})
				marker:setyaw(math.pi / 2)
				marker:get_luaentity().player_name = name
				table.insert(m, marker)
			end
		end

		protplus.markers[name] = m
		return true
	elseif pos1 and not pos2 then
		protplus:unmark(name, true)
		protplus.mark1[name] = minetest.add_entity(pos1, "protplus:pos1")
		protplus.mark1[name]:get_luaentity().player_name = name
		protplus.mpos1[name] = pos1
		return true
	elseif pos2 and not pos1 then
		protplus:unmark(name, nil, true)
		protplus.mark2[name] = minetest.add_entity(pos2, "protplus:pos2")
		protplus.mark2[name]:get_luaentity().player_name = name
		protplus.mpos2[name] = pos2
		return true
	end
end

-- [function] Unmark region
function protplus:unmark(name, pos1, pos2, main)
	local ret

	if pos1 then
		if protplus.mark1[name] then
			protplus.mark1[name]:remove()
			protplus.mark1[name] = nil
			ret = true
		end

		protplus.mpos1[name] = nil
	end

	if pos2 then
		if protplus.mark2[name] then
			protplus.mark2[name]:remove()
			protplus.mark2[name] = nil
			ret = true
		end

		protplus.mpos2[name] = nil
	end

	if pos1 and pos2 or main then
		if protplus.markers[name] then
			for _, entity in ipairs(protplus.markers[name]) do
				entity:remove()
				ret = true
			end
		end
	end

	return ret
end

---
--- Overrides/Registrations
---

-- [privilege] Protection permission
minetest.register_privilege("protplus", {
	description = "Ability to use advanced ProtPlus features",
})

-- [privilege] Protection bypass
minetest.register_privilege("protplus_bypass", {
	description = "Ability to manage and access all protected regions",
})

local original_is_protected = minetest.is_protected
-- [function] (Minetest) is Protected
function minetest.is_protected(pos, name)
	if not protplus:can_interact(pos, name) then
		return true
	else
		return original_is_protected(pos, name)
	end
end

-- [event] Display message on protection violation
minetest.register_on_protection_violation(function(pos, name)
	if not protplus:can_interact(pos, name) then
		local owners = table.concat(protplus:get_owners(pos) or {}, ", ")

		minetest.chat_send_player(name, minetest.colorize("red",
				("%s is protected by %s"):format(
						minetest.pos_to_string(pos), owners
		)))
	end
end)

-- [event] On HP change
minetest.register_on_player_hpchange(function(player, hp_change)
	if hp_change > 0 then
		return hp_change
	end

	local pos = vector.round(player:get_pos())
	local regions = protplus:is_protected(pos) or {}
	for _, r in pairs(regions) do
		if r.flags and r.flags.damage == false then
			return 0
		end
	end

	return hp_change
end, true)

-- [event] Save protected regions on shutdown
minetest.register_on_shutdown(function()
	protplus:save()
end)

-- [entity] Display
minetest.register_entity("protplus:display", {
	initial_properties = {
		visual = "upright_sprite",
		visual_size = {x=1.1, y=1.1},
		textures = {"protplus_border.png"},
		visual_size = {x=10, y=10},
		physical = false,
	},
	on_step = function(self, dtime)
		local name = self.player_name
		if not name then
			self.object:remove()
		elseif not protplus.markers[name] then
			protplus:unmark(name, true, true, true)
		end
	end,
	on_punch = function(self, hitter)
		protplus:unmark(self.player_name, true, true, true)
	end,
})

-- [entity] Position 1
minetest.register_entity("protplus:pos1", {
	initial_properties = {
		visual = "cube",
		visual_size = {x=1.1, y=1.1},
		textures = {"protplus_pos1.png", "protplus_pos1.png",
			"protplus_pos1.png", "protplus_pos1.png",
			"protplus_pos1.png", "protplus_pos1.png"},
		collisionbox = {-0.55, -0.55, -0.55, 0.55, 0.55, 0.55},
		physical = false,
	},
	on_step = function(self, dtime)
		local name = self.player_name
		if not name then
			self.object:remove()
		elseif not protplus.mark1[name] then
			protplus:unmark(name, true, nil, true)
		end
	end,
	on_punch = function(self, hitter)
		protplus:unmark(self.player_name, true, nil, true)
	end,
})

-- [entity] Position 2
minetest.register_entity("protplus:pos2", {
	initial_properties = {
		visual = "cube",
		visual_size = {x=1.1, y=1.1},
		textures = {"protplus_pos2.png", "protplus_pos2.png",
			"protplus_pos2.png", "protplus_pos2.png",
			"protplus_pos2.png", "protplus_pos2.png"},
		collisionbox = {-0.55, -0.55, -0.55, 0.55, 0.55, 0.55},
		physical = false,
	},
	on_step = function(self, dtime)
		local name = self.player_name
		if not name then
			self.object:remove()
		elseif not protplus.mark2[name] then
			protplus:unmark(name, nil, true, true)
		end
	end,
	on_punch = function(self, hitter)
		protplus:unmark(self.player_name, nil, true, true)
	end,
})

---
--- Load Resources
---

dofile(modpath.."/chat.lua")
dofile(modpath.."/wand.lua")
dofile(modpath.."/hud.lua")

-- Load protected regions
protplus:load()
