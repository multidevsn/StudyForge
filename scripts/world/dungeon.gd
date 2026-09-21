extends Node3D

@export var entrance_position := Vector3(12, 0, 20)
var dungeon_origin := Vector3(0, 1, 0)
var active := false
var boss_spawned := false

func _ready() -> void:
	add_to_group("dungeon")

func _process(_delta: float) -> void:
	var player: Node3D = get_tree().get_first_node_in_group("player") as Node3D
	if player == null: return
	if not active and player.global_position.distance_to(global_position) < 4.0 and Input.is_key_pressed(KEY_E):
		_enter(player)

func _enter(player: Node3D) -> void:
	active = true
	player.global_position = to_global(dungeon_origin + Vector3(0, 0, 6))
	_make_dungeon()
	var hud := get_tree().get_first_node_in_group("hud")
	if hud: hud.show_message("DONJON — Sanctuaire des Ombres. Trouve le gardien.")

func _make_dungeon() -> void:
	if boss_spawned: return
	boss_spawned = true
	for p in [Vector3(0,0,0), Vector3(8,0,0), Vector3(-8,0,0), Vector3(0,0,-8)]:
		var room := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(6, 0.4, 6)
		room.mesh = box
		room.position = dungeon_origin + p
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color("#282433")
		room.material_override = mat
		add_child(room)
	var boss_scene: CharacterBody3D = preload("res://scenes/enemies/Boss.tscn").instantiate() as CharacterBody3D
	if boss_scene == null:
		return
	boss_scene.position = dungeon_origin + Vector3(0, 0, -8)
	add_child(boss_scene)
