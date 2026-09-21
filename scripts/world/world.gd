extends Node3D

@export var world_size := 140.0
@export var terrain_resolution := 42
@export var tree_count := 70
@export var rock_count := 38

var rng := RandomNumberGenerator.new()
var sun: DirectionalLight3D
var time_of_day := 8.0
var defeated_enemies := 0
var save_system

func _ready() -> void:
	rng.seed = 777777
	save_system = preload("res://scripts/systems/save_system.gd").new()
	add_child(save_system)
	_build_world()
	call_deferred("_try_load")

func _process(delta: float) -> void:
	time_of_day = fmod(time_of_day + delta * 0.035, 24.0)
	var daylight := clamp(sin((time_of_day - 6.0) / 12.0 * PI), 0.08, 1.0)
	if sun:
		sun.light_energy = lerp(0.12, 1.25, daylight)
		sun.rotation_degrees = Vector3(-35.0 + (time_of_day - 12.0) * 7.0, -35.0, 0.0)
	if Engine.get_process_frames() % 1800 == 0:
		save_game()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F5:
			save_game()
		elif event.keycode == KEY_F9:
			_try_load()

func _build_world() -> void:
	_make_environment()
	_make_terrain()
	_make_river()
	_make_village()
	_make_npc()
	_make_enemy()
	for i in range(tree_count):
		_spawn_tree(_random_ground_position())
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
	var hills := sin(x * 0.085) * 2.4 + cos(z * 0.075) * 1.9
	var ridge := sin((x + z) * 0.045) * 1.6
	var valley := -abs(sin((x - 12.0) * 0.035)) * 1.2
	return hills + ridge + valley

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
			var a := Vector3(x0, _height(x0, z0), z0)
			var b := Vector3(x1, _height(x1, z0), z0)
			var c := Vector3(x1, _height(x1, z1), z1)
			var d := Vector3(x0, _height(x0, z1), z1)
			for v in [a,b,c,a,c,d]:
				st.set_uv(Vector2(v.x / world_size, v.z / world_size))
				st.add_vertex(v)
				faces.append(v)
	st.generate_normals()
	var mesh := st.commit()
	var material := StandardMaterial3D.new()
	material.albedo_color = Color("#4f6945")
	material.roughness = 1.0
	mesh.surface_set_material(0, material)
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
	plane.size = Vector2(18, world_size * 0.95)
	mesh.mesh = plane
	mesh.position = Vector3(25, _height(25, 0) + 0.08, 0)
	mesh.rotation_degrees.y = 12
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("#2c7290")
	mat.metallic = 0.08
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
	add_child(npc)

func _make_enemy() -> void:
	var enemy := preload("res://scenes/enemies/Enemy.tscn").instantiate()
	enemy.position = Vector3(18, _height(18, -24) + 0.05, -24)
	add_child(enemy)

func _random_ground_position() -> Vector3:
	var x := rng.randf_range(-world_size * 0.48, world_size * 0.48)
	var z := rng.randf_range(-world_size * 0.48, world_size * 0.48)
	if abs(x - 25.0) < 13.0:
		x -= 18.0
	if abs(x + 8.0) < 18.0 and abs(z + 10.0) < 20.0:
		x += 24.0
	return Vector3(x, _height(x, z), z)

func _spawn_tree(pos: Vector3) -> void:
	var root := Node3D.new()
	root.position = pos
	var trunk := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.35
	cyl.bottom_radius = 0.55
	cyl.height = 3.5
	trunk.mesh = cyl
	var bark := StandardMaterial3D.new()
	bark.albedo_color = Color("#5b3c29")
	trunk.material_override = bark
	trunk.position.y = 1.75
	root.add_child(trunk)
	var crown := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 2.0
	sphere.height = 4.0
	crown.mesh = sphere
	var leaves := StandardMaterial3D.new()
	leaves.albedo_color = Color("#294f35")
	leaves.roughness = 1.0
	crown.material_override = leaves
	crown.position.y = 4.1
	crown.scale = Vector3(1.0, 1.25, 1.0)
	root.add_child(crown)
	add_child(root)

func _spawn_rock(pos: Vector3) -> void:
	var rock := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = rng.randf_range(0.5, 1.5)
	mesh.height = mesh.radius * 1.4
	rock.mesh = mesh
	rock.position = pos + Vector3.UP * mesh.radius * 0.45
	rock.rotation = Vector3(rng.randf(), rng.randf(), rng.randf())
	rock.scale = Vector3(1.2, 0.7, 0.9)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("#62655d")
	mat.roughness = 1.0
	rock.material_override = mat
	add_child(rock)

func _make_ruins() -> void:
	for p in [Vector3(-30, _height(-30,-25), -25), Vector3(-34, _height(-34,-25), -25), Vector3(-32, _height(-32,-29), -29)]:
		var pillar := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(1.4, 4.5, 1.4)
		pillar.mesh = box
		pillar.position = p + Vector3.UP * 2.25
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color("#726b61")
		mat.roughness = 0.95
		pillar.material_override = mat
		add_child(pillar)

func on_enemy_defeated(_enemy: Node) -> void:
	defeated_enemies += 1

func save_game() -> void:
	var player := get_node_or_null("Player")
	if player and save_system.save_game(player, self):
		var hud := get_node_or_null("HUD")
		if hud and hud.has_method("show_message"):
			hud.show_message("Partie sauvegardée.")

func _try_load() -> void:
	var player := get_node_or_null("Player")
	if player and save_system.load_game(player, self):
		var hud := get_node_or_null("HUD")
		if hud and hud.has_method("show_message"):
			hud.show_message("Sauvegarde chargée.")
