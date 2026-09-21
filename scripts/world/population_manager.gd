extends Node3D

const CITIZEN_SCENE: PackedScene = preload("res://assets/external/quaternius/static_characters/EclyriaHero_static.glb")
const ENEMY_SCENE: PackedScene = preload("res://scenes/enemies/Enemy.tscn")
const CITIZEN_AGENT_SCRIPT: Script = preload("res://scripts/world/citizen.gd")

func _ready() -> void:
	call_deferred("_populate")

func _populate() -> void:
	_spawn_citizens()
	_spawn_guards()
	_spawn_enemy_camps()

func _height(x: float, z: float) -> float:
	return sin(x * 0.085) * 2.4 + cos(z * 0.075) * 1.9 + sin((x + z) * 0.045) * 1.6 - abs(sin((x - 12.0) * 0.035)) * 1.2

func _spawn_citizens() -> void:
	var positions: Array[Vector3] = [
		Vector3(-14.0, 0.0, -14.0), Vector3(-5.0, 0.0, -12.0),
		Vector3(-17.0, 0.0, -3.0), Vector3(2.0, 0.0, -8.0),
		Vector3(8.0, 0.0, 8.0), Vector3(-12.0, 0.0, 10.0),
		Vector3(-4.0, 0.0, 14.0), Vector3(10.0, 0.0, -3.0),
		Vector3(5.0, 0.0, 2.0)
	]
	for pos in positions:
		_spawn_citizen(pos, 0.92, false)

func _spawn_guards() -> void:
	var positions: Array[Vector3] = [
		Vector3(-25.0, 0.0, -10.0), Vector3(10.0, 0.0, -18.0),
		Vector3(-22.0, 0.0, 8.0), Vector3(10.0, 0.0, 14.0)
	]
	for pos in positions:
		_spawn_citizen(pos, 1.06, true)

func _spawn_citizen(pos: Vector3, model_scale: float, guard: bool) -> void:
	var citizen: CharacterBody3D = CharacterBody3D.new()
	citizen.name = "Guard_%d" % get_child_count() if guard else "Villager_%d" % get_child_count()
	citizen.set_script(CITIZEN_AGENT_SCRIPT)
	citizen.set("walk_speed", 1.1 if guard else 1.35)
	citizen.set("patrol_radius", 4.5 if guard else 7.0)
	citizen.position = Vector3(pos.x, _height(pos.x, pos.z), pos.z)

	var collider: CollisionShape3D = CollisionShape3D.new()
	var shape: CapsuleShape3D = CapsuleShape3D.new()
	shape.radius = 0.35
	shape.height = 1.75
	collider.shape = shape
	collider.position = Vector3(0.0, 0.88, 0.0)
	citizen.add_child(collider)

	var visual: Node3D = CITIZEN_SCENE.instantiate() as Node3D
	if visual == null:
		citizen.queue_free()
		return
	visual.name = "Visual"
	visual.scale = Vector3.ONE * model_scale
	citizen.add_child(visual)
	add_child(citizen)

func _spawn_enemy_camps() -> void:
	var positions: Array[Vector3] = [
		Vector3(23.0, 0.0, -28.0), Vector3(29.0, 0.0, -19.0),
		Vector3(30.0, 0.0, 9.0), Vector3(-28.0, 0.0, 27.0),
		Vector3(-34.0, 0.0, 18.0), Vector3(34.0, 0.0, 29.0)
	]
	var variants: Array[String] = ["goblin", "orc", "goblin", "orc", "goblin", "demon"]
	for i in range(positions.size()):
		var enemy: CharacterBody3D = ENEMY_SCENE.instantiate() as CharacterBody3D
		if enemy == null:
			continue
		enemy.name = "Wanderer_%02d" % i
		enemy.set("enemy_id", "wanderer_%02d" % i)
		enemy.set("max_health", 45 + (i % 3) * 15)
		enemy.set("move_speed", 1.8 + (i % 2) * 0.6)
		enemy.set("detection_range", 10.0 + (i % 3) * 3.0)
		enemy.set("enemy_variant", variants[i])
		var p: Vector3 = positions[i]
		enemy.position = Vector3(p.x, _height(p.x, p.z) + 0.05, p.z)
		add_child(enemy)
