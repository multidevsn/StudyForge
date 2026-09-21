# ECLYRIA — Production Asset Library

This directory contains production assets explicitly selected for ECLYRIA. No legacy StudyForge learning-app assets are reused.

## Active real environment assets

### Quaternius — village
- house_1.glb
- house_2.glb
- house_3.glb
- inn.glb
- blacksmith.glb
- market_stand_1.glb
- well.glb

### Quaternius — nature
- CommonTree_1.glb
- CommonTree_2.glb
- Bush_Common.glb
- rock_1.glb
- rock_2.glb

These static assets are active in the village, central valley and streamed regions.

## Character pipeline

The active game scenes now use real Quaternius 3D assets:
- static character mesh for the player
- the same real humanoid base asset for villagers, guards and merchants, with material variations
- static Goblin, Orc and Demon meshes for enemies

The character models are static derivatives of the original real Quaternius GLBs with skeleton/animation data removed to avoid the previous Godot 4.7 import crash.

The original rigged GLBs remain preserved in Git history for a future isolated animation-import pass.

## Planned external character assets

Quaternius Universal Base Characters, RPG Character Pack, Ultimate Modular Men/Female packs and Bestiary - Dungeon Monsters Kit remain approved sources. Their rigged assets will be reintroduced one at a time after isolated Godot 4.7 import validation.

## Environment expansion

The current world now combines real Quaternius buildings/nature with authored gameplay props: street lamps, carts, barrels, crates, fences and campfire landmarks.

## Import rules

1. Never reuse old StudyForge assets.
2. Keep third-party media inside assets/external/.
3. Record source URL, creator, license and any conversion/optimization.
4. Do not commit Godot-generated .import caches.
5. Keep collisions as dedicated gameplay components when source collisions are not reliable.

Quaternius' official packs are available in formats including glTF/GLB and are licensed for personal and commercial use under the terms stated on each pack page. 