# ECLYRIA V0.2 — External Assets

The V0.1 prototype remains asset-independent. This folder is the controlled entry point for production assets.

## Approved sources

### Quaternius
- Universal Base Characters: https://quaternius.com/packs/universalbasecharacters.html
- Universal Animation Library: https://quaternius.com/packs/universalanimationlibrary.html
- Universal Animation Library 2: https://quaternius.com/packs/universalanimationlibrary2.html
- Medieval Village MegaKit: https://quaternius.com/packs/medievalvillagemegakit.html
- Stylized Nature MegaKit: https://quaternius.com/
- Fantasy Props MegaKit: https://quaternius.com/

All selected Quaternius packs above are CC0 and provide glTF/FBX/other formats; the character and animation packs are designed for humanoid retargeting and Godot workflows.

### Poly Haven
- Library: https://polyhaven.com/
- License: https://polyhaven.com/license

Poly Haven assets are CC0. Use it for selected PBR materials, rocks, props and HDRIs.

## Import policy

1. Do not copy anything from the old StudyForge project.
2. Keep external assets under assets/external/<source>/.
3. Prefer glTF/GLB for Godot.
4. Keep original source filenames where practical.
5. Record the exact source URL and license for every imported pack.
6. Optimize textures and meshes for the GL Compatibility renderer.
7. Do not commit generated import caches.

## V0.2 target asset set

- Player: Universal Base Character
- Player locomotion/combat: Universal Animation Library + Library 2
- Village: Medieval Village MegaKit
- Nature: Stylized Nature MegaKit
- Props: Fantasy Props MegaKit
- Selected PBR/HDRI: Poly Haven
