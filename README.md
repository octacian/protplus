Protection Plus [protplus]
==========================

ProtPlus isn't just "Yet Another Protection Mod", instead, it is the most featured protection mod to date. With the combination of chatcommand-based protection as is seen in ShadowNinja's [areas](https://forum.minetest.net/viewtopic.php?t=7239), protection blocks as seen in TenPlus1's [protector](https://github.com/tenplus1/protector), and per-chunk claims as seen in [landrush](https://forum.minetest.net/viewtopic.php?id=4799), ProtPlus offers everything you could need from a protection mod. **Note:** The latter two features are still in progress.

ProtPlus has an advanced API including overlap checking, renaming, member and owner management, and more. These API features can be accessed via the protection blocks (WIP), chatcommands, and partially via the WorldEdit-like wand

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

Authors of media (textures, models, and sounds)
-----------------------------------------------
Everything not listed in here:
octacian (CC BY-SA 3.0)

Mod: WorldEdit (?):
* `protplus_border.png`
* `protplus_pos1.png`
* `protplus_pos2.png`
* `protplus_wand.png`