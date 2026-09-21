extends Node3D

const TREE_SCENE_1: PackedScene = preload("res://assets/external/quaternius/nature/CommonTree_1.glb")
const TREE_SCENE_2: PackedScene = preload("res://assets/external/quaternius/nature/CommonTree_2.glb")
const BUSH_SCENE: PackedScene = preload("res://assets/external/quaternius/nature/Bush_Common.glb")
const BUSH_FLOWERS_SCENE: PackedScene = preload("res://assets/external/quaternius/nature/Bush_Common_Flowers.glb")
const ROCK_SCENE_1: PackedScene = preload("res://assets/external/quaternius/nature/rock_1.glb")
const ROCK_SCENE_2: PackedScene = preload("res://assets/external/quaternius/nature/rock_2.glb")
const GRASS_SHORT_SCENE: PackedScene = preload("res://assets/external/quaternius/nature/Grass_Common_Short.glb")
const GRASS_TALL_SCENE: PackedScene = preload("res://assets/external/quaternius/nature/Grass_Common_Tall.glb")

var coord := Vector2i.ZERO
var region_size := 80.0
var resolution := 18
var seed_value := 0
var rng := RandomNumberGenerator.new()

func setup(region_coord: Vector2i, size: float, world_seed: int) -> void:
	coord = region_coord
	region_size = size
	seed_value = world_seed
	rng.seed = int(hash(Vector3i(coord.x, coord.y, world_seed)))
	_build()

func _height(x: float, z: float) -> float:
	return sin(x * 0.085) * 2.4 + cos(z * 0.075) * 1.9 + sin((x + z) * 0.045) * 1.6 - abs(sin((x - 12.0) * 0.035)) * 1.2

func _build() -> void:
	if get_child_count() > 0:
		return
	var origin := Vector3(coord.x * region_size, 0.0, coord.y * region_size)
	_make_terrain(origin)
	_make_props(origin)

func _make_terrain(origin: Vector3) -> void:
	var body := StaticBody3D.new()
	body.name = "RegionTerrain_%d_%d" % [coord.x, coord.y]
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var half := region_size * 0.5
	var step := region_size / float(resolution - 1)
	var faces := PackedVector3Array()
	for z in range(resolution - 1):
		for x in range(resolution - 1):
			var x0 := -half + x * step
			var x1 := x0 + step
			var z0 := -half + z * step
			var z1 := z0 + step
			for v in [
				Vector3(x0, _height(origin.x + x0, origin.z + z0), z0),
				Vector3(x1, _height(origin.x + x1, origin.z + z0), z0),
				Vector3(x1, _height(origin.x + x1, origin.z + z1), z1),
				Vector3(x0, _height(origin.x + x0, origin.z + z0), z0),
				Vector3(x1, _height(origin.x + x1, origin.z + z1), z1),
				Vector3(x0, _height(origin.x + x0, origin.z + z1), z1)
			]:
				st.add_vertex(v)
				faces.append(v)
	st.generate_normals()
	var mesh := st.commit()
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("#526b49")
	mat.roughness = 1.0
	mesh.surface_set_material(0, mat)
	var visual := MeshInstance3D.new()
	visual.mesh = mesh
	visual.position = origin
	visual.visibility_range_end = region_size * 2.2
	body.add_child(visual)
	var collision := CollisionShape3D.new()
	var shape := ConcavePolygonShape3D.new()
	shape.set_faces(faces)
	collision.shape = shape
	collision.position = origin
	body.add_child(collision)
	add_child(body)

func _make_props(origin: Vector3) -> void:
	for i in range(16):
		var x := rng.randf_range(-region_size * 0.45, region_size * 0.45)
		var z := rng.randf_range(-region_size * 0.45, region_size * 0.45)
		_spawn_tree(Vector3(origin.x + x, _height(origin.x + x, origin.z + z), origin.z + z))
	for i in range(9):
		var x := rng.randf_range(-region_size * 0.46, region_size * 0.46)
		var z := rng.randf_range(-region_size * 0.46, region_size * 0.46)
		_spawn_bush(Vector3(origin.x + x, _height(origin.x + x, origin.z + z), origin.z + z))
	for i in range(10):
		var x := rng.randf_range(-region_size * 0.46, region_size * 0.46)
		var z := rng.randf_range(-region_size * 0.46, region_size * 0.46)
		_spawn_rock(Vector3(origin.x + x, _height(origin.x + x, origin.z + z), origin.z + z))
	for i in range(18):
		var gx := rng.randf_range(-region_size * 0.46, region_size * 0.46)
		var gz := rng.randf_range(-region_size * 0.46, region_size * 0.46)
		_spawn_grass(Vector3(origin.x + gx, _height(origin.x + gx, origin.z + gz), origin.z + gz))

func _spawn_tree(pos: Vector3) -> void:
	var tree_scene: PackedScene = TREE_SCENE_1 if rng.randi_range(0, 1) == 0 else TREE_SCENE_2
	if tree_scene == null:
		return
	var instance: Node3D = tree_scene.instantiate() as Node3D
	if instance == null:
		return
	instance.position = pos
	instance.rotation.y = rng.randf_range(-PI, PI)
	instance.scale = Vector3.ONE * rng.randf_range(0.8, 1.15)
	add_child(instance)
	for node in instance.find_children("*", "VisualInstance3D", true, false):
		if node is VisualInstance3D:
			(node as VisualInstance3D).visibility_range_end = region_size * 1.35
			node.add_to_group("stream_optimized")

func _spawn_bush(pos: Vector3) -> void:
	var bush_scene: PackedScene = BUSH_SCENE if rng.randi_range(0, 3) != 0 else BUSH_FLOWERS_SCENE
	if bush_scene == null:
		return
	var instance: Node3D = bush_scene.instantiate() as Node3D
	if instance == null:
		return
	instance.position = pos
	instance.rotation.y = rng.randf_range(-PI, PI)
	instance.scale = Vector3.ONE * rng.randf_range(0.75, 1.2)
	add_child(instance)
	for node in instance.find_children("*", "VisualInstance3D", true, false):
		if node is VisualInstance3D:
			(node as VisualInstance3D).visibility_range_end = region_size * 1.1
			node.add_to_group("stream_optimized")

func _spawn_rock(pos: Vector3) -> void:
	var rock_scene: PackedScene = ROCK_SCENE_1 if rng.randi_range(0, 1) == 0 else ROCK_SCENE_2
	if rock_scene == null:
		return
	var instance: Node3D = rock_scene.instantiate() as Node3D
	if instance == null:
		return
	instance.position = pos
	instance.rotation = Vector3(0.0, rng.randf_range(-PI, PI), 0.0)
	instance.scale = Vector3.ONE * rng.randf_range(0.75, 1.2)
	add_child(instance)
	for node in instance.find_children("*", "VisualInstance3D", true, false):
		if node is VisualInstance3D:
			(node as VisualInstance3D).visibility_range_end = region_size * 1.15
			node.add_to_group("stream_optimized")


func _spawn_grass(pos: Vector3) -> void:
	var grass_scene: PackedScene = GRASS_SHORT_SCENE if rng.randi_range(0, 1) == 0 else GRASS_TALL_SCENE
	var instance: Node3D = grass_scene.instantiate() as Node3D
	if instance == null:
		return
	instance.position = pos
	instance.rotation.y = rng.randf_range(-PI, PI)
	instance.scale = Vector3.ONE * rng.randf_range(0.8, 1.2)
	add_child(instance)
	for node in instance.find_children("*", "VisualInstance3D", true, false):
		if node is VisualInstance3D:
			(node as VisualInstance3D).visibility_range_end = region_size * 0.8
			node.add_to_group("stream_optimized")
