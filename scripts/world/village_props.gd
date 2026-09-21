extends Node3D

const CART_SCENE: PackedScene = preload("res://assets/external/quaternius/props/cart.glb")
const BARREL_SCENE: PackedScene = preload("res://assets/external/quaternius/props/barrel.glb")
const CRATE_SCENE: PackedScene = preload("res://assets/external/quaternius/props/crate_wooden.glb")
const BONFIRE_SCENE: PackedScene = preload("res://assets/external/quaternius/props/bonfire.glb")
const FENCE_SCENE: PackedScene = preload("res://assets/external/quaternius/props/fence.glb")
const LANTERN_SCENE: PackedScene = preload("res://assets/external/quaternius/props/lantern_wall.glb")
const ANVIL_SCENE: PackedScene = preload("res://assets/external/quaternius/props/anvil.glb")
const WEAPON_STAND_SCENE: PackedScene = preload("res://assets/external/quaternius/props/weapon_stand.glb")
const MARKET_SCENE: PackedScene = preload("res://assets/external/quaternius/props/market_stand_2.glb")
const BELL_TOWER_SCENE: PackedScene = preload("res://assets/external/quaternius/props/bell_tower.glb")

func _ready() -> void:
	_build_real_village_props()

func _build_real_village_props() -> void:
	_spawn_asset(CART_SCENE, Vector3(-15.0, 0.0, -1.0), 1.0, 0.18)
	_spawn_asset(CART_SCENE, Vector3(10.0, 0.0, 4.0), 0.9, -0.55)

	_spawn_asset(BARREL_SCENE, Vector3(-19.0, 0.0, -3.0), 0.9, 0.0)
	_spawn_asset(BARREL_SCENE, Vector3(-20.0, 0.0, -4.0), 0.85, 0.4)
	_spawn_asset(BARREL_SCENE, Vector3(-3.0, 0.0, -4.0), 0.9, -0.25)
	_spawn_asset(BARREL_SCENE, Vector3(18.0, 0.0, 7.0), 0.95, 0.7)
	_spawn_asset(BARREL_SCENE, Vector3(-15.0, 0.0, 16.0), 0.9, -0.4)

	_spawn_asset(CRATE_SCENE, Vector3(-18.0, 0.0, 6.0), 0.9, 0.1)
	_spawn_asset(CRATE_SCENE, Vector3(4.0, 0.0, 13.0), 1.0, -0.2)
	_spawn_asset(CRATE_SCENE, Vector3(15.0, 0.0, -8.0), 0.85, 0.4)
	_spawn_asset(CRATE_SCENE, Vector3(-5.0, 0.0, 17.0), 0.9, -0.5)

	_spawn_asset(BONFIRE_SCENE, Vector3(-1.0, 0.0, 6.0), 1.0, 0.0)
	_spawn_asset(BONFIRE_SCENE, Vector3(15.0, 0.0, 1.0), 0.9, 0.7)
	_spawn_asset(BONFIRE_SCENE, Vector3(-24.0, 0.0, -1.0), 0.9, -0.4)

	for z in [-18.0, -10.0, -2.0, 6.0, 14.0]:
		_spawn_asset(FENCE_SCENE, Vector3(-22.0, 0.0, z), 1.0, 0.0)
		_spawn_asset(FENCE_SCENE, Vector3(-18.0, 0.0, z), 1.0, 0.0)

	for p in [
		Vector3(-19.0, 2.5, -15.0), Vector3(-7.0, 2.5, -15.0),
		Vector3(4.0, 2.5, -11.0), Vector3(12.0, 2.5, -2.0),
		Vector3(12.0, 2.5, 11.0), Vector3(-17.0, 2.5, 12.0)
	]:
		_spawn_asset(LANTERN_SCENE, p, 0.9, 0.0)

	_spawn_asset(ANVIL_SCENE, Vector3(-8.0, 0.0, 18.0), 0.9, 0.2)
	_spawn_asset(WEAPON_STAND_SCENE, Vector3(-10.0, 0.0, 18.0), 0.9, 0.0)

	_spawn_asset(MARKET_SCENE, Vector3(9.0, 0.0, 15.0), 1.0, -0.1)
	_spawn_asset(BELL_TOWER_SCENE, Vector3(19.0, 0.0, -11.0), 1.0, 0.0)

func _spawn_asset(scene: PackedScene, pos: Vector3, scale_factor: float, rotation_y: float) -> void:
	if scene == null:
		return
	var instance: Node3D = scene.instantiate() as Node3D
	if instance == null:
		return
	instance.position = pos
	instance.rotation.y = rotation_y
	instance.scale = Vector3.ONE * scale_factor
	add_child(instance)

	for node in instance.find_children("*", "VisualInstance3D", true, false):
		if node is VisualInstance3D:
			node.add_to_group("stream_optimized")
			node.visibility_range_end = 100.0
