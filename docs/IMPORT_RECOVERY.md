# ECLYRIA import recovery

Godot was closing during the GLB import pass. The project therefore temporarily removes the four skeletal GLBs from the active `res://` scan:

- EclyriaHero.glb
- Goblin.glb
- Orc.glb
- Demon.glb

The gameplay scenes now use procedural fallback meshes, so the project can be opened and tested independently of those imports.

## Local recovery

1. Close Godot completely.
2. Pull the latest `main` branch.
3. Delete the local `.godot/` folder inside the project.
4. Reopen the project.
5. Confirm the editor remains open and the main scene loads.

The removed GLB assets are still preserved in Git history and can be reintroduced later one by one.

Godot 4.3 has documented GLTF/GLB editor crash regressions, including crashes during bone remapping and GLTF re-import.