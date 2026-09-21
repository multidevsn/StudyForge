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

The project currently uses procedural/modular 3D character visuals for the player, villagers, guards, merchants and enemies. This deliberately avoids the skeletal GLB editor-import path that caused Godot to close during the previous art pass.

The previously embedded skeletal character/creature GLBs are preserved in Git history and are not part of the active import set.

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