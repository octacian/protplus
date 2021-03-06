Protection Plus [protplus]
==========================

ProtPlus isn't just "Yet Another Protection Mod", instead, it is the most featured protection mod to date. With the combination of chatcommand-based protection as is seen in ShadowNinja's [areas](https://forum.minetest.net/viewtopic.php?t=7239), protection blocks as seen in TenPlus1's [protector](https://github.com/tenplus1/protector), and per-chunk claims as seen in [landrush](https://forum.minetest.net/viewtopic.php?id=4799), ProtPlus offers everything you could need from a protection mod. **Note:** The latter two features are still in progress.

ProtPlus has an advanced API including overlap checking, renaming, member and owner management, and more. These API features can be accessed via the protection blocks (WIP), chatcommands, and partially via the WorldEdit-like wand.

Protected regions also allow setting flags, which can change other game variables such as preventing damage or showing an HUD in the bottom-right corner of the screen. You can even temporarily remove protection from a region using the `open` flag, without having to actually remove the region itself. These flags can be managed via the `/protflags` chatcommand. Valid flags can be accessed via `/protflags help` and `protflags help <flag>`.

To learn about the API, read API.md.

Chatcommands
------------

ProtPlus introduces many chatcommands in order to manage protected regions. The parameters accepted by these chatcommands are documented via the `/help` chatcommand. All ProtPlus chatcommands require the `protplus` privilege, and the `protplus_bypass` privilege is required to access and modify protection that you don't own.

* `protpoint`: Set/unset protection selection points
* `protect`: Protect selected region
* `protlist`: List regions protected by you or another player
* `protdel`: Remove protection from a region
* `protrename`: Rename protected region
* `protmove`: Move/resize a protected region
* `protshow`: Highlight protected region
* `protowner`: Get or change the owner of a region
* `protmember`: Get or change the member list of a region
* `protflags`: Get or set flags for a protected area

Configuration
-------------

Most timers and other variables used in ProtPlus can be configured directly from the advanced settings menu in the protplus subsection of the top-level Mods section. You can also configure ProtPlus directly from `minetest.conf` with the settings listed below.

| Name                    | Type  | Default | Description                       |
| ----------------------- | ----- | ------- | --------------------------------- |
| protplus.display_remove | float | 60      | Time to live for display entities |

Authors of media (textures, models, and sounds)
-----------------------------------------------
Everything not listed in here:
octacian (CC BY-SA 3.0)

Mod: WorldEdit (?):
* `protplus_border.png`
* `protplus_pos1.png`
* `protplus_pos2.png`
* `protplus_wand.png`
