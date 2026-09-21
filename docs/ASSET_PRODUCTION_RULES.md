# ECLYRIA — Asset production rules

## Direction artistique

ECLYRIA uses a coherent stylized-fantasy low-poly look centered on Quaternius assets. The active pipeline avoids placeholder primitives for final visual content.

## Active real 3D asset families

### Characters
- assets/external/quaternius/static_characters/EclyriaHero_static.glb
- assets/external/quaternius/static_characters/Goblin_static.glb
- assets/external/quaternius/static_characters/Orc_static.glb
- assets/external/quaternius/static_characters/Demon_static.glb

The static character files are derived from the original rigged GLBs by removing animations, skin references and JOINTS/WEIGHTS attributes. The geometry/material payload remains from the real Quaternius model. This is a compatibility step for the current Godot 4.7 import problem, not a procedural replacement.

### Nature / plains
- CommonTree_1.glb
- CommonTree_2.glb
- Bush_Common.glb
- Bush_Common_Flowers.glb
- Grass_Common_Short.glb
- Grass_Common_Tall.glb
- rock_1.glb
- rock_2.glb

### Village / props
- house_1.glb, house_2.glb, house_3.glb
- inn.glb, blacksmith.glb, market_stand_1.glb, well.glb
- anvil.glb, barrel.glb, bell_tower.glb, bonfire.glb
- cart.glb, crate_wooden.glb, fence.glb
- lantern_wall.glb, market_stand_2.glb, weapon_stand.glb

### Ruins / dungeon
- column_broken.glb
- gravestone_decorative.glb
- crypt.glb
- floor_tile_large.glb
- wall.glb, wall_cracked.glb
- arch.glb, pillar_decorated.glb
- torch_lit.glb, chest_gold.glb

## Scene architecture

Gameplay scenes own gameplay collision shapes; decorative source meshes do not become gameplay hitboxes automatically.

Environment assets are preloaded at script scope where they are spawned repeatedly. This avoids repeated runtime resource resolution.

Large decorative meshes are placed in the stream_optimized group and use visibility ranges for distance culling.

## Import safety

Do not place the original rigged character GLBs back into the active asset folders until they are individually validated in Godot 4.7. The original files remain recoverable from Git history.

## Provenance

Primary source family: Quaternius. The official packs provide glTF/OBJ/FBX assets and the relevant packs are published for game use under their current license terms. See assets/external/quaternius/QUATERNIUS_CREDITS.md for source records.
