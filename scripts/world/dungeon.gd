extends Node3D

@export var entrance_position: Vector3 = Vector3(12.0, 0.0, 20.0)

const FLOOR_SCENE: PackedScene = preload("res://assets/external/quaternius/dungeon/floor_tile_large.glb")
const WALL_SCENE: PackedScene = preload("res://assets/external/quaternius/dungeon/wall.glb")
const CRACKED_WALL_SCENE: PackedScene = preload("res://assets/external/quaternius/dungeon/wall_cracked.glb")
const ARCH_SCENE: PackedScene = preload("res://assets/external/quaternius/dungeon/arch.glb")
const PILLAR_SCENE: PackedScene = preload("res://assets/external/quaternius/dungeon/pillar_decorated.glb")
const TORCH_SCENE: PackedScene = preload("res://assets/external/quaternius/dungeon/torch_lit.glb")
const CHEST_SCENE: PackedScene = preload("res://assets/external/quaternius/dungeon/chest_gold.glb")
const BOSS_SCENE: PackedScene = preload("res://scenes/enemies/Boss.tscn")

var dungeon_origin: Vector3 = Vector3(0.0, 1.0, 0.0)
var active: bool = false
var boss_spawned: bool = false

func _ready() -> void:
	add_to_group("dungeon")

func _process(_delta: float) -> void:
	var player: Node3D = get_tree().get_first_node_in_group("player") as Node3D
	if player == null:
		return
	if not active and player.global_position.distance_to(global_position) < 5.0 and Input.is_key_pressed(KEY_E):
		_enter(player)

func _enter(player: Node3D) -> void:
	active = true
	player.global_position = to_global(dungeon_origin + Vector3(0.0, 0.5, 8.0))
	_make_dungeon()
	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.show_message("DONJON — Sanctuaire des Ombres. Trouve le gardien.")

func _make_dungeon() -> void:
	if boss_spawned:
		return
	boss_spawned = true

	# Four connected rooms built from real modular dungeon pieces.
	for p in [
		Vector3(0.0, 0.0, 0.0),
		Vector3(8.0, 0.0, 0.0),
		Vector3(-8.0, 0.0, 0.0),
		Vector3(0.0, 0.0, -8.0),
		Vector3(8.0, 0.0, -8.0),
		Vector3(-8.0, 0.0, -8.0)
	]:
		_spawn_asset(FLOOR_SCENE, dungeon_origin + p, 1.0)

	for p in [
		Vector3(-4.0, 0.0, 4.0), Vector3(4.0, 0.0, 4.0),
		Vector3(-12.0, 0.0, 4.0), Vector3(12.0, 0.0, 4.0),
		Vector3(-12.0, 0.0, -12.0), Vector3(12.0, 0.0, -12.0)
	]:
		_spawn_asset(PILLAR_SCENE, dungeon_origin + p, 0.9)

	for p in [
		Vector3(0.0, 0.0, 4.0), Vector3(0.0, 0.0, -12.0)
	]:
		_spawn_asset(ARCH_SCENE, dungeon_origin + p, 1.0)

	for p in [
		Vector3(-4.0, 0.0, 7.5), Vector3(4.0, 0.0, 7.5),
		Vector3(-12.0, 0.0, -4.0), Vector3(12.0, 0.0, -4.0),
		Vector3(-4.0, 0.0, -12.0), Vector3(4.0, 0.0, -12.0)
	]:
		_spawn_asset(WALL_SCENE, dungeon_origin + p, 1.0)

	for p in [
		Vector3(-8.0, 0.0, -4.0), Vector3(8.0, 0.0, -4.0),
		Vector3(-8.0, 0.0, -12.0)
	]:
		_spawn_asset(CRACKED_WALL_SCENE, dungeon_origin + p, 1.0)

	for p in [
		Vector3(-5.0, 0.0, 3.5), Vector3(5.0, 0.0, 3.5),
		Vector3(-12.0, 0.0, -8.0), Vector3(12.0, 0.0, -8.0),
		Vector3(0.0, 0.0, -11.5)
	]:
		_spawn_asset(TORCH_SCENE, dungeon_origin + p, 0.85)

	_spawn_asset(CHEST_SCENE, dungeon_origin + Vector3(0.0, 0.0, -8.0), 0.9)

	var boss: CharacterBody3D = BOSS_SCENE.instantiate() as CharacterBody3D
	if boss == null:
		return
	boss.position = dungeon_origin + Vector3(0.0, 0.0, -8.0)
	add_child(boss)

func _spawn_asset(scene: PackedScene, position: Vector3, scale_factor: float) -> void:
	if scene == null:
		return
	var instance: Node3D = scene.instantiate() as Node3D
	if instance == null:
		return
	instance.position = position
	instance.scale = Vector3.ONE * scale_factor
	add_child(instance)
	for node in instance.find_children("*", "VisualInstance3D", true, false):
		if node is VisualInstance3D:
			(node as VisualInstance3D).visibility_range_end = 100.0
			node.add_to_group("stream_optimized")
