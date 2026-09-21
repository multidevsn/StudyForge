extends Node3D

var house_scenes: Array[PackedScene] = []

func _ready() -> void:
	for path in [
		"res://assets/external/quaternius/village/house_1.glb",
		"res://assets/external/quaternius/village/house_2.glb",
		"res://assets/external/quaternius/village/house_3.glb"
	]:
		var scene: PackedScene = load(path)
		if scene:
			house_scenes.append(scene)
	_build_village()

func _build_village() -> void:
	var road_mat := _mat("#8a7358")
	for z in [-18.0, -10.0, -2.0, 6.0, 14.0]:
		_make_box(Vector3(30, 0.08, 2.8), Vector3(-8, 0.05, z), road_mat)

	var positions := [
		Vector3(-22, 0, -18),
		Vector3(-22, 0, 4),
		Vector3(6, 0, -18)
	]
	for i in range(positions.size()):
		_make_real_building(positions[i], house_scenes[i % max(house_scenes.size(), 1)])

	_make_real_building(Vector3(6, 0, 4), load("res://assets/external/quaternius/village/inn.glb"))
	_make_real_building(Vector3(-8, 0, 18), load("res://assets/external/quaternius/village/blacksmith.glb"))
	_make_real_building(Vector3(7, 0, 15), load("res://assets/external/quaternius/village/market_stand_1.glb"))
	_make_real_building(Vector3(-1, 0, -1), load("res://assets/external/quaternius/village/well.glb"))

func _make_real_building(pos: Vector3, scene: PackedScene) -> void:
	if scene == null:
		return
	var root := StaticBody3D.new()
	root.position = pos
	add_child(root)
	var visual := scene.instantiate() as Node3D
	if visual == null:
		root.queue_free()
		return
	visual.scale = Vector3.ONE * 1.65
	root.add_child(visual)
	for node in visual.find_children("*", "VisualInstance3D", true, false):
		if node is VisualInstance3D:
			(node as VisualInstance3D).add_to_group("stream_optimized")
			(node as VisualInstance3D).visibility_range_end = 120.0

	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(7.6, 4.0, 6.6)
	collision.shape = shape
	collision.position = Vector3(0, 2.0, 0)
	root.add_child(collision)

func _make_box(size: Vector3, pos: Vector3, mat: Material, parent: Node = self) -> MeshInstance3D:
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mesh.mesh = box
	mesh.position = pos
	mesh.material_override = mat
	parent.add_child(mesh)
	return mesh

func _mat(hex: String) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(hex)
	mat.roughness = 0.9
	return mat
