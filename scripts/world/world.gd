extends Node3D

@export var world_size := 140.0
@export var tree_count := 90
@export var rock_count := 45

var rng := RandomNumberGenerator.new()
var sun: DirectionalLight3D
var time_of_day := 8.0

func _ready() -> void:
	rng.seed = 777777
	_build_world()

func _process(delta: float) -> void:
	time_of_day = fmod(time_of_day + delta * 0.035, 24.0)
	var daylight := clamp(sin((time_of_day - 6.0) / 12.0 * PI), 0.08, 1.0)
	if sun:
		sun.light_energy = lerp(0.18, 1.2, daylight)
		sun.rotation_degrees.x = -35.0 + (time_of_day - 12.0) * 7.0

func _build_world() -> void:
	_make_environment()
	_make_ground()
	_make_river()
	for i in range(tree_count): _spawn_tree(_random_ground_position())
	for i in range(rock_count): _spawn_rock(_random_ground_position())
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
	env.ambient_light_energy = 0.65
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env_node.environment = env
	add_child(env_node)

	sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-45, -35, 0)
	sun.light_energy = 1.0
	sun.shadow_enabled = true
	add_child(sun)

func _make_ground() -> void:
	var body := StaticBody3D.new()
	body.name = "Ground"
	var mesh := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(world_size, world_size)
	plane.subdivide_width = 32
	plane.subdivide_depth = 32
	mesh.mesh = plane
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("#4f6945")
	mat.roughness = 1.0
	mesh.material_override = mat
	body.add_child(mesh)

	var collider := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(world_size, 0.5, world_size)
	collider.shape = shape
	collider.position.y = -0.25
	body.add_child(collider)
	add_child(body)

func _make_river() -> void:
	var mesh := MeshInstance3D.new()
	mesh.name = "River"
	var plane := PlaneMesh.new()
	plane.size = Vector2(18, world_size * 0.95)
	mesh.mesh = plane
	mesh.position = Vector3(25, 0.025, 0)
	mesh.rotation_degrees.y = 12
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("#2c7290")
	mat.metallic = 0.05
	mat.roughness = 0.18
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color.a = 0.82
	mesh.material_override = mat
	add_child(mesh)

func _random_ground_position() -> Vector3:
	var x := rng.randf_range(-world_size * 0.48, world_size * 0.48)
	var z := rng.randf_range(-world_size * 0.48, world_size * 0.48)
	if abs(x - 25.0) < 13.0: x -= 18.0
	return Vector3(x, 0, z)

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
	for p in [Vector3(-30,0,-25), Vector3(-34,0,-25), Vector3(-32,0,-29)]:
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
