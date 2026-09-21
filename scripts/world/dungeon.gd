extends Node3D

const FLOOR_SCENE: PackedScene = preload("res://assets/external/quaternius/dungeon/floor_tile_large.glb")
const WALL_SCENE: PackedScene = preload("res://assets/external/quaternius/dungeon/wall.glb")
const CRACKED_WALL_SCENE: PackedScene = preload("res://assets/external/quaternius/dungeon/wall_cracked.glb")
const ARCH_SCENE: PackedScene = preload("res://assets/external/quaternius/dungeon/arch.glb")
const PILLAR_SCENE: PackedScene = preload("res://assets/external/quaternius/dungeon/pillar_decorated.glb")
const TORCH_SCENE: PackedScene = preload("res://assets/external/quaternius/dungeon/torch_lit.glb")
const CHEST_SCENE: PackedScene = preload("res://assets/external/quaternius/dungeon/chest_gold.glb")
const BOSS_SCENE: PackedScene = preload("res://scenes/enemies/Boss.tscn")

@export var entrance_position: Vector3 = Vector3(12.0, 0.0, 20.0)
@export var room_size: float = 28.0

var dungeon_origin := Vector3(0.0, 1.0, 0.0)
var active := false
var built := false

func _ready() -> void:
	add_to_group("dungeon")

func _process(_delta: float) -> void:
	if active:
		return
	var player: Node3D = get_tree().get_first_node_in_group("player") as Node3D
	if player == null:
		return
	if player.global_position.distance_to(global_position) < 5.0 and Input.is_key_pressed(KEY_E):
		_enter(player)

func _enter(player: Node3D) -> void:
	active = true
	player.global_position = to_global(dungeon_origin + Vector3(0.0, 1.4, 9.0))
	_build_dungeon()
	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.show_message("DONJON — Sanctuaire des Ombres. Trouve le gardien.")

func _build_dungeon() -> void:
	if built:
		return
	built = true

	var half: float = room_size * 0.5
	var tile_step: float = 4.0

	for x in range(-3, 4):
		for z in range(-3, 4):
			_spawn_asset(FLOOR_SCENE, dungeon_origin + Vector3(float(x) * tile_step, 0.0, float(z) * tile_step), 1.0, 0.0)

	for x in range(-3, 4):
		_spawn_asset(WALL_SCENE, dungeon_origin + Vector3(float(x) * tile_step, 2.0, -half), 1.0, 0.0)
		_spawn_asset(CRACKED_WALL_SCENE if x % 3 == 0 else WALL_SCENE, dungeon_origin + Vector3(float(x) * tile_step, 2.0, half), 1.0, PI)

	for z in range(-2, 3):
		_spawn_asset(WALL_SCENE, dungeon_origin + Vector3(-half, 2.0, float(z) * tile_step), 1.0, PI * 0.5)
		_spawn_asset(WALL_SCENE, dungeon_origin + Vector3(half, 2.0, float(z) * tile_step), 1.0, -PI * 0.5)

	for p in [
		Vector3(-10.0, 1.0, -10.0), Vector3(10.0, 1.0, -10.0),
		Vector3(-10.0, 1.0, 10.0), Vector3(10.0, 1.0, 10.0)
	]:
		_spawn_asset(PILLAR_SCENE, dungeon_origin + p, 1.0, 0.0)

	_spawn_asset(ARCH_SCENE, dungeon_origin + Vector3(0.0, 1.0, -half + 0.8), 1.0, 0.0)

	for p in [
		Vector3(-9.0, 1.2, -13.0), Vector3(9.0, 1.2, -13.0),
		Vector3(-9.0, 1.2, 13.0), Vector3(9.0, 1.2, 13.0)
	]:
		_spawn_asset(TORCH_SCENE, dungeon_origin + p, 1.0, 0.0)

	_spawn_asset(CHEST_SCENE, dungeon_origin + Vector3(0.0, 0.6, -5.0), 1.0, PI)

	var boss: CharacterBody3D = BOSS_SCENE.instantiate() as CharacterBody3D
	if boss:
		boss.position = dungeon_origin + Vector3(0.0, 0.0, -9.0)
		add_child(boss)

	_add_collision()

func _add_collision() -> void:
	var body: StaticBody3D = StaticBody3D.new()
	body.name = "DungeonCollision"
	add_child(body)

	var floor_shape: BoxShape3D = BoxShape3D.new()
	floor_shape.size = Vector3(room_size, 1.0, room_size)

	var floor_collision: CollisionShape3D = CollisionShape3D.new()
	floor_collision.shape = floor_shape
	floor_collision.position = dungeon_origin + Vector3(0.0, -0.15, 0.0)
	body.add_child(floor_collision)

	for p in [
		dungeon_origin + Vector3(0.0, 2.0, -room_size * 0.5),
		dungeon_origin + Vector3(0.0, 2.0, room_size * 0.5)
	]:
		var wall_shape: BoxShape3D = BoxShape3D.new()
		wall_shape.size = Vector3(room_size, 4.0, 0.6)
		var collision: CollisionShape3D = CollisionShape3D.new()
		collision.shape = wall_shape
		collision.position = p
		body.add_child(collision)

	for p in [
		dungeon_origin + Vector3(-room_size * 0.5, 2.0, 0.0),
		dungeon_origin + Vector3(room_size * 0.5, 2.0, 0.0)
	]:
		var wall_shape: BoxShape3D = BoxShape3D.new()
		wall_shape.size = Vector3(0.6, 4.0, room_size)
		var collision: CollisionShape3D = CollisionShape3D.new()
		collision.shape = wall_shape
		collision.position = p
		body.add_child(collision)

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
			node.visibility_range_end = room_size * 3.0
