# ECLYRIA — Production Asset Library

This directory contains only production assets explicitly selected for ECLYRIA. No legacy StudyForge learning-app assets are reused.

## Imported real assets

### Quaternius — characters
- `characters/EclyriaHero.glb` — Universal Base Characters, Superhero Male derivative.
- Used by the player, elder NPC and merchants.
- CC0 1.0 provenance documented in `QUATERNIUS_CREDITS.md`.

### Quaternius — village
- `village/house_1.glb`
- `village/house_2.glb`
- `village/house_3.glb`
- `village/inn.glb`
- `village/blacksmith.glb`
- `village/market_stand_1.glb`
- `village/well.glb`
- Used by the playable village.

### Quaternius — nature
- `nature/CommonTree_1.glb`
- `nature/CommonTree_2.glb`
- `nature/Bush_Common.glb`
- `nature/rock_1.glb`
- `nature/rock_2.glb`
- Used by both the central zone and streamed regions.

### Quaternius — creatures
- `monsters/Goblin.glb`
- `monsters/Orc.glb`
- `monsters/Demon.glb`
- Goblin is the current first enemy; Demon is the current dungeon boss visual. Orc is reserved for enemy variants.

## Approved sources still planned
- Universal Animation Library + Library 2
- Fantasy Props MegaKit
- Additional Stylized Nature MegaKit assets
- Selected Poly Haven PBR/HDRI assets

## Import rules
1. Never reuse old StudyForge assets.
2. Keep third-party media inside `assets/external/quaternius/` or `assets/external/polyhaven/`.
3. Record source URL, creator, license and any conversion/optimization.
4. Prefer GLB/glTF for Godot 4.x.
5. Do not commit Godot-generated `.import` caches.
6. Keep collisions as dedicated gameplay components where the source model collision is not reliable.

## Performance target
ECLYRIA remains on Godot's GL Compatibility renderer. Imported meshes are subject to visibility ranges and streamed-region culling.
