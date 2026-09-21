extends Node3D

const ANVIL_SCENE: PackedScene = preload("res://assets/external/quaternius/props/anvil.glb")
const BARREL_SCENE: PackedScene = preload("res://assets/external/quaternius/props/barrel.glb")
const BELL_TOWER_SCENE: PackedScene = preload("res://assets/external/quaternius/props/bell_tower.glb")
const BONFIRE_SCENE: PackedScene = preload("res://assets/external/quaternius/props/bonfire.glb")
const CART_SCENE: PackedScene = preload("res://assets/external/quaternius/props/cart.glb")
const CRATE_SCENE: PackedScene = preload("res://assets/external/quaternius/props/crate_wooden.glb")
const LANTERN_SCENE: PackedScene = preload("res://assets/external/quaternius/props/lantern_wall.glb")
const MARKET_SCENE: PackedScene = preload("res://assets/external/quaternius/props/market_stand_2.glb")
const WEAPON_STAND_SCENE: PackedScene = preload("res://assets/external/quaternius/props/weapon_stand.glb")
const FENCE_SCENE: PackedScene = preload("res://assets/external/quaternius/props/fence.glb")

func _ready() -> void:
	_spawn_prop(BELL_TOWER_SCENE, Vector3(-7.0, 0.0, -6.0), 1.0)
	_spawn_prop(MARKET_SCENE, Vector3(8.0, 0.0, 15.0), 1.15)
	_spawn_prop(WEAPON_STAND_SCENE, Vector3(-11.0, 0.0, 16.5), 0.9)
	_spawn_prop(ANVIL_SCENE, Vector3(-6.5, 0.0, 17.0), 0.9)

	for p in [
		Vector3(-18.0, 0.0, -3.0), Vector3(-3.0, 0.0, -4.0),
		Vector3(10.0, 0.0, 7.0), Vector3(18.0, 0.0, 5.0),
		Vector3(-15.0, 0.0, 15.0), Vector3(5.0, 0.0, 17.0)
	]:
		_spawn_prop(BARREL_SCENE, p, 0.82)

	for p in [
		Vector3(-20.0, 0.0, 6.0), Vector3(4.0, 0.0, 13.0),
		Vector3(15.0, 0.0, -7.0), Vector3(-4.0, 0.0, 18.0)
	]:
		_spawn_prop(CRATE_SCENE, p, 0.75)

	_spawn_prop(CART_SCENE, Vector3(-15.0, 0.0, -1.0), 1.0)
	_spawn_prop(CART_SCENE, Vector3(10.0, 0.0, 3.5), 0.85)
	_spawn_prop(BONFIRE_SCENE, Vector3(-1.0, 0.0, 6.0), 0.8)
	_spawn_prop(BONFIRE_SCENE, Vector3(15.0, 0.0, 1.0), 0.7)

	for p in [
		Vector3(-21.0, 0.0, -10.0), Vector3(-10.0, 0.0, -17.0),
		Vector3(3.0, 0.0, -12.0), Vector3(13.0, 0.0, 2.0)
	]:
		_spawn_prop(LANTERN_SCENE, p, 0.8)

	_spawn_prop(FENCE_SCENE, Vector3(-22.0, 0.0, -10.0), 1.0)

func _spawn_prop(scene: PackedScene, position: Vector3, scale_factor: float) -> void:
	if scene == null:
		return
	var instance: Node3D = scene.instantiate() as Node3D
	if instance == null:
		return
	instance.position = position
	instance.scale = Vector3.ONE * scale_factor
	instance.rotation.y = randf_range(-PI, PI)
	add_child(instance)
	for node in instance.find_children("*", "VisualInstance3D", true, false):
		if node is VisualInstance3D:
			(node as VisualInstance3D).visibility_range_end = 110.0
			node.add_to_group("stream_optimized")
