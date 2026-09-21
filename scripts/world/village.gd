extends Node3D

func _ready() -> void:
	_build_village()

func _build_village() -> void:
	var road_mat := _mat("#8a7358")
	for z in [-18.0, -10.0, -2.0, 6.0, 14.0]:
		_make_box(Vector3(30, 0.08, 2.8), Vector3(-8, 0.05, z), road_mat)
	for pos in [Vector3(-22,0,-18), Vector3(-22,0,4), Vector3(6,0,-18), Vector3(6,0,4), Vector3(-8,0,18)]:
		_make_house(pos)

func _make_house(pos: Vector3) -> void:
	var root := Node3D.new()
	root.position = pos
	add_child(root)
	var wall := _mat("#9b7b59")
	var roof := _mat("#503d38")
	_make_box(Vector3(8, 4, 7), Vector3(0, 2, 0), wall, root)
	_make_box(Vector3(8.8, 1.2, 7.8), Vector3(0, 4.45, 0), roof, root)
	var door := _mat("#3b2923")
	_make_box(Vector3(1.5, 2.4, 0.18), Vector3(0, 1.2, 3.58), door, root)
	var window := _mat("#8ac5d1")
	for x in [-2.2, 2.2]:
		_make_box(Vector3(1.2, 1.1, 0.15), Vector3(x, 2.0, 3.58), window, root)

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
