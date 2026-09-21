# ECLYRIA — Production Asset Library

ECLYRIA uses a real third-party 3D asset pipeline based on Quaternius CC0 packs, with gameplay logic separated from visual assets.

## Active real character assets

- `static_characters/EclyriaHero_static.glb` — real Quaternius humanoid mesh, statically derived from the previously embedded Universal Base Character source.
- `static_characters/Goblin_static.glb` — real Quaternius creature mesh.
- `static_characters/Orc_static.glb` — real Quaternius creature mesh.
- `static_characters/Demon_static.glb` — real Quaternius creature mesh.

The active character GLBs are mesh-only variants with skeletal skin/animation data removed. This keeps the actual visual model while avoiding the skeletal GLB import path that previously caused the Godot editor to close.

## Active real environment assets

### Village and architecture
- house_1.glb
- house_2.glb
- house_3.glb
- inn.glb
- blacksmith.glb
- market_stand_1.glb
- well.glb

### Nature
- CommonTree_1.glb
- CommonTree_2.glb
- Bush_Common.glb
- Bush_Common_Flowers.glb
- Grass_Common_Short.glb
- Grass_Common_Tall.glb
- rock_1.glb
- rock_2.glb

### Village props
- cart.glb
- barrel.glb
- crate_wooden.glb
- bonfire.glb
- fence.glb
- lantern_wall.glb
- anvil.glb
- weapon_stand.glb
- market_stand_2.glb
- bell_tower.glb

### Dungeon
- floor_tile_large.glb
- wall.glb
- wall_cracked.glb
- arch.glb
- pillar_decorated.glb
- torch_lit.glb
- chest_gold.glb

## Architecture rules

1. Visual assets live under `assets/external/quaternius/`.
2. Gameplay collisions are authored separately when source collisions are unsuitable.
3. Character gameplay nodes own movement/combat; imported GLBs remain visual children.
4. Real assets are reused through PackedScene instantiation rather than recreated with primitive meshes.
5. Large environment visuals use visibility ranges and the streaming optimization group.
6. Skeletal assets are introduced one at a time only after Godot 4.7 import validation.

Quaternius' Stylized Nature MegaKit and Medieval Village MegaKit provide textured glTF/GLB assets and Godot-ready source versions; the published pack pages state CC0 usage for personal, educational and commercial projects. 