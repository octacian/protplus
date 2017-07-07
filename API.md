ProtPlus API
============

### Global Variables
There are several global variables accessible via the `protplus` namespace. These variables are used to keep track of markers per-player.

- `protplus.markers`: Entity `self` references to main protection markers
- `protplus.mark1`: Entity `self` references to `pos1` protection markers
- `protplus.mark2`: Entity `self` references to `pos2` protection markers
- `protplus.mpos1`: Positional references to `pos1` protection markers
- `protplus.mpos2`: Positional references to `pos2` protection markers

### API

`protplus:load()`
* Loads region data into `self.regions`

`protplus:save()`
* Saves region data from `self.regions` into `<world directory>/protplus.mt`

`protplus:get_regions()`
* Returns all regions stored in `self.regions`

`protplus:get_region(id)`
* Returns region by id
* `id`: Region ID (numerical)

`protplus:is_protected(pos)`
* Returns `table` containing list of regions protecting the position or `nil`
* `pos`: Positional vector

`protplus:get_owner_by_id(id)`
* Returns owner of region (identified by ID)
* `id`: Region ID (numerical)

`protplus:get_members_by_id(id)`
* Returns `table` containing a list of members of a region (identified by ID)
* `id`: Region ID (numerical)

`protplus:get_owners(pos)`
* Returns `table` containing a list of all players owning regions at the position
* `pos`: Positional vector

`protplus:get_members(pos)`
* Returns `table` containing a list of all members who are a member of the regions protecting the position
* `pos`: Positional vector

`protplus:is_owner(id, name)`
* Returns `true` if the username provided matches the owner of the region (identified by ID)
* `id`: Region ID (numerical)
* `name`: Name of player

`protplus:is_member(id, name)`
* Returns `true` if the username provided matches a member of the region (identified by ID)
* `id`: Region ID (numerical)
* `name`: Name of player

`protplus:is_admin(name)`
* Returns `true` if the player has the `protplus_bypass` privilege or matches the server administrator username
* `name`: Name of player

`protplus:can_modify(id, name)`
* Returns `true` if the player can modify the region (e.g. manage members)
* `id`: Region ID (numerical)
* `name`: Name of player

`protplus:can_interact(pos, name)`
* Returns `true` if the player can interact with the node at the position
* `pos`: Positional vector
* `name`: Name of player

`protplus:get_player_regions(name, format)`
* Returns two `table`s containing all regions of which the player is the owner (first return value) and is a member (second return value)
* `name`: Player name
* `format`: `true` causes table entries to be formatted in a method suitable for printing to chat

`protplus:get_intersect(pos1, pos2)`
* Returns `table` containing regions intersecting the two positions
* `pos1`, `pos2`: Positional vector

`protplus:can_protect(name, pos1, pos2)`
* Returns `true` if the player can protect the region between the positions (i.e if the region does not intersect with others not owned by the player or the player is an administrator)
* `name`: Name of player
* `pos1`, `pos2`: Positional vector

`protplus:get_flags(id, format)`
* Returns `table` of region flag
* Table: `{damage = BOOL}`
* `id`: Region ID (numerical)
* `format`: `true` causes table entries to be formatted as a string suitable for chat (e.g. `"damage = true"`)

`protplus:set_flags(id, new_flags)`
* Returns `true` if flags are updated
* Does not overwrite flags entirely, but only those provided in the `new_flags` table
* `new_flags`: Table of new flag values

`protplus:add(owner, name, pos1, pos2)`
* Returns `number` indicating the ID of the protected region or `nil`
* `owner`: Name of owning player
* `name`: Name for region
* `pos1`, `pos2`: Positional vector

`protplus:move(id, pos1, pos2)`
* Returns `true` if the region positions were successfully updated to the positions provided
* `pos1`, `pos2`: Positional vector

`protplus:rename(id, name)`
* Returns `true` if the region was renamed
* `id`: Region ID (numerical)
* `name`: Name for region

`protplus:remove(id)`
* Returns `true` if the region was removed
* `id`: Region ID (numerical)

`protplus:set_owner(id, owner)`
* Returns `true` if the owner of the region was updated
* `id`: Region ID (numerical)
* `owner`: Name of owning player

`protplus:add_member(id, member)`
* Returns `true` if member was added to region
* `id`: Region ID (numerical)
* `member`: Name of member player

`protplus:remove_member(id, member)`
* Returns `true` if the member was removed from the region
* `id`: Region ID (numerical)
* `member`: Name of member player

`protplus:mark(name, pos1, pos2)`
* Returns `true` if region marker entities were added
* If only one position value is provided, only that particular marker is added
* If both position values are provided, only the border entity is added
* `name`: Name of player
* `pos1`, `pos2`: Positional vector

`protplus:unmark(name, pos1, pos2, main)`
* Returns `true` if region marker entities were removed
* Only the markers set to `true` are removed
* `name`: Name of player
* `pos1`, `pos2`, `main`: Boolean indicating which marker(s) should be removed