extends Node3D

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
	for i in range(10):
		var x := rng.randf_range(-region_size * 0.46, region_size * 0.46)
		var z := rng.randf_range(-region_size * 0.46, region_size * 0.46)
		_spawn_rock(Vector3(origin.x + x, _height(origin.x + x, origin.z + z), origin.z + z))

func _spawn_tree(pos: Vector3) -> void:
	var root := Node3D.new()
	root.position = pos
	var trunk := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.25
	cyl.bottom_radius = 0.42
	cyl.height = 3.0
	trunk.mesh = cyl
	var bark := StandardMaterial3D.new()
	bark.albedo_color = Color("#5b3c29")
	trunk.material_override = bark
	trunk.position.y = 1.5
	trunk.visibility_range_end = region_size * 1.35
	root.add_child(trunk)
	var crown := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 1.65
	sphere.height = 3.3
	crown.mesh = sphere
	var leaves := StandardMaterial3D.new()
	leaves.albedo_color = Color("#2e5237")
	crown.material_override = leaves
	crown.position.y = 3.6
	crown.visibility_range_end = region_size * 1.35
	root.add_child(crown)
	add_child(root)

func _spawn_rock(pos: Vector3) -> void:
	var rock := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = rng.randf_range(0.45, 1.1)
	mesh.height = mesh.radius * 1.4
	rock.mesh = mesh
	rock.position = pos + Vector3.UP * mesh.radius * 0.45
	rock.scale = Vector3(1.2, 0.7, 0.9)
	rock.visibility_range_end = region_size * 1.15
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("#62655d")
	rock.material_override = mat
	add_child(rock)
