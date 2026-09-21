extends Node3D

var citizen_visual_script := preload("res://scripts/characters/humanoid_visual.gd")
var citizen_agent_script := preload("res://scripts/world/citizen.gd")
var enemy_scene := preload("res://scenes/enemies/Enemy.tscn")

func _ready() -> void:
	call_deferred("_populate")

func _populate() -> void:
	_spawn_citizens()
	_spawn_guards()
	_spawn_enemy_camps()

func _height(x: float, z: float) -> float:
	return sin(x * 0.085) * 2.4 + cos(z * 0.075) * 1.9 + sin((x + z) * 0.045) * 1.6 - abs(sin((x - 12.0) * 0.035)) * 1.2

func _spawn_citizens() -> void:
	var data: Array = [
		[Vector3(-14,0,-14), "villager", Color("#c98d67"), Color("#405f78"), Color("#b88955")],
		[Vector3(-5,0,-12), "villager", Color("#a9684f"), Color("#6b4735"), Color("#bd8a43")],
		[Vector3(-17,0,-3), "villager", Color("#d29a72"), Color("#5e4c77"), Color("#8c6a44")],
		[Vector3(2,0,-8), "villager", Color("#8c583f"), Color("#3f6c55"), Color("#c57f3b")],
		[Vector3(-2,0,2), "merchant", Color("#b97857"), Color("#704a2e"), Color("#d3ac5a")],
		[Vector3(8,0,8), "villager", Color("#d2a07e"), Color("#425873"), Color("#a65f55")],
		[Vector3(-12,0,10), "villager", Color("#7e4e3f"), Color("#7b3e44"), Color("#c8a04e")],
		[Vector3(-4,0,14), "villager", Color("#c18263"), Color("#5e6e43"), Color("#a98a57")],
		[Vector3(10,0,-3), "villager", Color("#d29c79"), Color("#6f513d"), Color("#9c6049")]
	]
	for entry in data:
		_spawn_citizen(entry[0], entry[1], entry[2], entry[3], entry[4])

func _spawn_guards() -> void:
	var positions: Array[Vector3] = [
		Vector3(-25,0,-10), Vector3(10,0,-18), Vector3(-22,0,8), Vector3(10,0,14)
	]
	for pos in positions:
		_spawn_citizen(pos, "guard", Color("#bd825f"), Color("#37465f"), Color("#c9ad60"), 1.08)

func _spawn_citizen(pos: Vector3, citizen_role: String, skin: Color, outfit: Color, accent: Color, size := 1.0) -> void:
	var citizen := CharacterBody3D.new()
	citizen.name = "%s_%d" % [citizen_role.capitalize(), get_child_count()]
	citizen.position = Vector3(pos.x, _height(pos.x, pos.z), pos.z)
	citizen.set_script(citizen_agent_script)
	citizen.walk_speed = 1.1 if citizen_role == "guard" else 1.35
	citizen.patrol_radius = 4.5 if citizen_role == "guard" else 7.0
	citizen.role = citizen_role

	var collider := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.35
	shape.height = 1.75
	collider.shape = shape
	collider.position = Vector3(0, 0.88, 0)
	citizen.add_child(collider)

	var visual := Node3D.new()
	visual.name = "Visual"
	visual.set_script(citizen_visual_script)
	visual.role = citizen_role
	visual.skin_color = skin
	visual.outfit_color = outfit
	visual.accent_color = accent
	visual.scale_factor = size
	citizen.add_child(visual)
	add_child(citizen)

func _spawn_enemy_camps() -> void:
	var positions: Array[Vector3] = [
		Vector3(23,0,-28), Vector3(29,0,-19), Vector3(30,0,9),
		Vector3(-28,0,27), Vector3(-34,0,18), Vector3(34,0,29)
	]
	var variants: Array[String] = ["goblin", "orc", "goblin", "orc", "goblin", "demon"]
	for i in range(positions.size()):
		var enemy := enemy_scene.instantiate()
		enemy.name = "Wanderer_%02d" % i
		enemy.enemy_id = "wanderer_%02d" % i
		enemy.max_health = 45 + (i % 3) * 15
		enemy.move_speed = 1.8 + (i % 2) * 0.6
		enemy.detection_range = 10.0 + (i % 3) * 3.0
		enemy.enemy_variant = variants[i]
		var p: Vector3 = positions[i]
		enemy.position = Vector3(p.x, _height(p.x, p.z) + 0.05, p.z)
		add_child(enemy)
