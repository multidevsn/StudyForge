# ECLYRIA roadmap

## V1.1 — Real asset production pass

### Characters
- [x] Real Quaternius humanoid for player
- [x] Real Quaternius humanoid for NPCs/merchants
- [x] Real Quaternius Goblin
- [x] Real Quaternius Orc
- [x] Real Quaternius Demon
- [x] Gameplay collision separated from visual models
- [ ] Reintroduce skeletal character rigs one-by-one in Godot 4.7
- [ ] Retarget Universal Animation Library 2

### Environment
- [x] Real Quaternius houses and village buildings
- [x] Real Quaternius carts, barrels, crates, fences and bonfires
- [x] Real Quaternius lanterns, market prop, anvil and weapon stand
- [x] Real Quaternius trees, bushes, flowers and grass
- [x] Real Quaternius rocks
- [x] Real Quaternius modular dungeon floor/walls/arches/pillars/torches/chest
- [x] World streaming with visibility ranges
- [ ] More biome-specific asset sets
- [ ] Real PBR terrain materials from Poly Haven
- [ ] LOD/impostor pass

### Combat / presentation
- [ ] Real weapon model attached to player equipment
- [ ] Combat VFX
- [ ] Hit reactions
- [ ] Navigation / crowd avoidance
- [ ] Runtime profiling on target hardware

Godot recommends glTF 2.0/GLB for 3D scenes; OBJ is more limited for modern material/skeleton workflows. ECLYRIA therefore prefers GLB for the active static asset pipeline. 