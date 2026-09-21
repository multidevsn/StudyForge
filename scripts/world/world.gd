extends Node3D

@export var world_size := 80.0
@export var terrain_resolution := 34
@export var tree_count := 38
@export var rock_count := 20

var rng := RandomNumberGenerator.new()
var sun: DirectionalLight3D
var time_of_day := 8.0
var defeated_enemies := 0
var defeated_enemy_ids: Dictionary = {}
var save_system
var rpg_system
var region_streamer
var event_manager

func _ready() -> void:
	rng.seed = 777777
	rpg_system = preload("res://scripts/systems/rpg_system.gd").new()
	rpg_system.name = "RPGSystem"
	add_child(rpg_system)
	save_system = preload("res://scripts/systems/save_system.gd").new()
	add_child(save_system)

	var audio := preload("res://scripts/systems/audio_manager.gd").new()
	audio.name = "AudioManager"
	add_child(audio)
	var optimization := preload("res://scripts/systems/optimization_manager.gd").new()
	optimization.name = "OptimizationManager"
	add_child(optimization)
	region_streamer = preload("res://scripts/world/region_streamer.gd").new()
	region_streamer.name = "RegionStreamer"
	add_child(region_streamer)
	event_manager = preload("res://scripts/world/event_manager.gd").new()
	event_manager.name = "EventManager"
	add_child(event_manager)

	_build_world()
	call_deferred("_try_load")

func _process(delta: float) -> void:
	time_of_day = fmod(time_of_day + delta * 0.035, 24.0)
	var daylight: float = clampf(sin((time_of_day - 6.0) / 12.0 * PI), 0.08, 1.0)
	if sun:
		sun.light_energy = lerpf(0.12, 1.25, daylight)
		sun.rotation_degrees = Vector3(-35.0 + (time_of_day - 12.0) * 7.0, -35.0, 0.0)
	if Engine.get_process_frames() % 1800 == 0:
		save_game()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F5:
			save_game()
		elif event.keycode == KEY_F9:
			_try_load()
		elif event.keycode == KEY_J:
			var hud := get_tree().get_first_node_in_group("hud")
			if hud and rpg_system:
				hud.show_message(rpg_system.quests_text())

func _build_world() -> void:
	_make_environment()
	_make_terrain()
	_make_river()
	_make_village()
	_make_npc()
	_make_merchant()
	_make_enemy()
	_make_dungeon()
	for i in range(tree_count):
		_spawn_tree(_random_ground_position())
	for i in range(24):
		_spawn_bush(_random_ground_position())
	for i in range(rock_count):
		_spawn_rock(_random_ground_position())
	_make_ruins()

func _make_environment() -> void:
	var env_node := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var material := ProceduralSkyMaterial.new()
	material.sky_top_color = Color("#10233d")
	material.sky_horizon_color = Color("#d49b70")
	material.ground_bottom_color = Color("#18251f")
	material.ground_horizon_color = Color("#756b59")
	sky.sky_material = material
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.7
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env_node.environment = env
	add_child(env_node)
	sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-45, -35, 0)
	sun.light_energy = 1.0
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 80.0
	add_child(sun)

func _height(x: float, z: float) -> float:
	return sin(x * 0.085) * 2.4 + cos(z * 0.075) * 1.9 + sin((x + z) * 0.045) * 1.6 - abs(sin((x - 12.0) * 0.035)) * 1.2

func _make_terrain() -> void:
	var body := StaticBody3D.new()
	body.name = "Terrain"
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var half := world_size * 0.5
	var step := world_size / float(terrain_resolution - 1)
	var faces := PackedVector3Array()
	for z in range(terrain_resolution - 1):
		for x in range(terrain_resolution - 1):
			var x0 := -half + x * step
			var x1 := x0 + step
			var z0 := -half + z * step
			var z1 := z0 + step
			for v in [Vector3(x0,_height(x0,z0),z0),Vector3(x1,_height(x1,z0),z0),Vector3(x1,_height(x1,z1),z1),Vector3(x0,_height(x0,z0),z0),Vector3(x1,_height(x1,z1),z1),Vector3(x0,_height(x0,z1),z1)]:
				st.add_vertex(v)
				faces.append(v)
	st.generate_normals()
	var mesh := st.commit()
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("#4f6945")
	mat.roughness = 1.0
	mesh.surface_set_material(0, mat)
	var visual := MeshInstance3D.new()
	visual.mesh = mesh
	body.add_child(visual)
	var collision := CollisionShape3D.new()
	var shape := ConcavePolygonShape3D.new()
	shape.set_faces(faces)
	collision.shape = shape
	body.add_child(collision)
	add_child(body)

func _make_river() -> void:
	var mesh := MeshInstance3D.new()
	mesh.name = "River"
	var plane := PlaneMesh.new()
	plane.size = Vector2(12, world_size * 0.95)
	mesh.mesh = plane
	mesh.position = Vector3(25, _height(25, 0) + 0.08, 0)
	mesh.rotation_degrees.y = 12
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("#2c7290")
	mat.roughness = 0.16
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color.a = 0.84
	mesh.material_override = mat
	add_child(mesh)

func _make_village() -> void:
	var village := preload("res://scenes/world/Village.tscn").instantiate()
	village.position = Vector3(-8, _height(-8, -10), -10)
	add_child(village)

func _make_npc() -> void:
	var npc := preload("res://scenes/world/NPC.tscn").instantiate()
	npc.position = Vector3(-8, _height(-8, -4), -4)
	npc.name = "Elder"
	add_child(npc)

func _make_merchant() -> void:
	for p in [Vector3(-4, _height(-4, -2), -2), Vector3(-12, _height(-12, -1), -1)]:
		var merchant := preload("res://scenes/world/Merchant.tscn").instantiate()
		merchant.position = p
		add_child(merchant)

func _make_enemy() -> void:
	if defeated_enemy_ids.has("enemy_0"):
		return
	var enemy := preload("res://scenes/enemies/Enemy.tscn").instantiate()
	enemy.enemy_id = "enemy_0"
	enemy.position = Vector3(18, _height(18, -24) + 0.05, -24)
	add_child(enemy)

func _make_dungeon() -> void:
	var dungeon := preload("res://scenes/world/Dungeon.tscn").instantiate()
	dungeon.position = Vector3(12, _height(12, 20) + 1.0, 20)
	add_child(dungeon)

func _random_ground_position() -> Vector3:
	var x := rng.randf_range(-world_size * 0.48, world_size * 0.48)
	var z := rng.randf_range(-world_size * 0.48, world_size * 0.48)
	if abs(x - 25.0) < 10.0:
		x -= 12.0
	if abs(x + 8.0) < 18.0 and abs(z + 10.0) < 20.0:
		x += 24.0
	return Vector3(x, _height(x, z), z)

func _spawn_tree(pos: Vector3) -> void:
	var tree_paths: Array[String] = [
		"res://assets/external/quaternius/nature/CommonTree_1.glb",
		"res://assets/external/quaternius/nature/CommonTree_2.glb"
	]
	var tree_scene: PackedScene = load(tree_paths[rng.randi_range(0, tree_paths.size() - 1)])
	if tree_scene == null:
		return
	var instance: Node3D = tree_scene.instantiate() as Node3D
	if instance == null:
		return
	instance.position = pos
	instance.rotation.y = rng.randf_range(-PI, PI)
	var scale_value := rng.randf_range(0.85, 1.15)
	instance.scale = Vector3.ONE * scale_value
	add_child(instance)
	for node in instance.find_children("*", "VisualInstance3D", true, false):
		if node is VisualInstance3D:
			(node as VisualInstance3D).visibility_range_end = 85.0
			node.add_to_group("stream_optimized")

func _spawn_bush(pos: Vector3) -> void:
	var bush_scene: PackedScene = load("res://assets/external/quaternius/nature/Bush_Common.glb")
	if bush_scene == null:
		return
	var instance: Node3D = bush_scene.instantiate() as Node3D
	if instance == null:
		return
	instance.position = pos
	instance.rotation.y = rng.randf_range(-PI, PI)
	instance.scale = Vector3.ONE * rng.randf_range(0.75, 1.25)
	add_child(instance)
	for node in instance.find_children("*", "VisualInstance3D", true, false):
		if node is VisualInstance3D:
			(node as VisualInstance3D).visibility_range_end = 65.0
			node.add_to_group("stream_optimized")

func _spawn_rock(pos: Vector3) -> void:
	var rock := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = rng.randf_range(0.5,1.5)
	mesh.height = mesh.radius * 1.4
	rock.mesh = mesh
	rock.position = pos + Vector3.UP * mesh.radius * 0.45
	rock.scale = Vector3(1.2,0.7,0.9)
	rock.visibility_range_end = 80.0
	rock.add_to_group("stream_optimized")
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("#62655d")
	rock.material_override = mat
	add_child(rock)

func _make_ruins() -> void:
	for p in [Vector3(-30,_height(-30,-25),-25),Vector3(-34,_height(-34,-25),-25),Vector3(-32,_height(-32,-29),-29)]:
		var pillar := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(1.4,4.5,1.4)
		pillar.mesh = box
		pillar.position = p + Vector3.UP * 2.25
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color("#726b61")
		pillar.material_override = mat
		add_child(pillar)

func on_enemy_defeated(enemy: Node) -> void:
	defeated_enemies += 1
	var enemy_id := str(enemy.get("enemy_id"))
	if enemy_id != "":
		defeated_enemy_ids[enemy_id] = true
	if rpg_system:
		rpg_system.register_enemy_defeat()

func serialize_world_state() -> Dictionary:
	return {
		"defeated_enemies": defeated_enemies,
		"defeated_enemy_ids": defeated_enemy_ids,
		"region_streaming": region_streamer.serialize_state() if region_streamer else {},
		"event_index": event_manager.event_index if event_manager else 0
	}

func restore_world_state(data: Dictionary) -> void:
	defeated_enemies = int(data.get("defeated_enemies", defeated_enemies))
	var ids = data.get("defeated_enemy_ids", {})
	if typeof(ids) == TYPE_DICTIONARY:
		defeated_enemy_ids = ids
	if event_manager:
		event_manager.event_index = int(data.get("event_index", event_manager.event_index))
	if region_streamer:
		region_streamer.restore_state(data.get("region_streaming", {}))
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy):
			continue
		var enemy_id := str(enemy.get("enemy_id"))
		if enemy_id != "" and defeated_enemy_ids.has(enemy_id):
			enemy.queue_free()

func save_game() -> void:
	var player := get_node_or_null("Player")
	if player and save_system.save_game(player, self):
		var hud := get_node_or_null("HUD")
		if hud and hud.has_method("show_message"): hud.show_message("Partie sauvegardée.")

func _try_load() -> void:
	var player := get_node_or_null("Player")
	if player and save_system.load_game(player, self):
		var hud := get_node_or_null("HUD")
		if hud and hud.has_method("show_message"): hud.show_message("Sauvegarde chargée.")
