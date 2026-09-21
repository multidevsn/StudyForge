extends Node3D

## V0.2 visual pass: extra village landmarks while external asset packs
## are being integrated. These are procedural placeholders, not reused assets.

func _ready() -> void:
	_make_well(Vector3(-8, 0, -10))
	_make_market(Vector3(2, 0, -2))
	_make_fence(Vector3(-22, 0, -10), 18.0)

func _mat(hex: String) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(hex)
	m.roughness = 0.9
	return m

func _box(size: Vector3, pos: Vector3, material: Material, parent: Node3D = self) -> void:
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mesh.mesh = box
	mesh.position = pos
	mesh.material_override = material
	parent.add_child(mesh)

func _make_well(pos: Vector3) -> void:
	var root := Node3D.new()
	root.position = pos
	add_child(root)
	var stone := _mat("#6d6b63")
	for i in range(10):
		var a := TAU * float(i) / 10.0
		var p := Vector3(cos(a) * 1.5, 0.55, sin(a) * 1.5)
		_box(Vector3(0.7, 1.1, 0.7), p, stone, root)
	var wood := _mat("#543725")
	_box(Vector3(0.22, 3.0, 0.22), Vector3(-1.1, 1.9, 0), wood, root)
	_box(Vector3(0.22, 3.0, 0.22), Vector3(1.1, 1.9, 0), wood, root)
	_box(Vector3(2.5, 0.22, 0.22), Vector3(0, 3.0, 0), wood, root)

func _make_market(pos: Vector3) -> void:
	var root := Node3D.new()
	root.position = pos
	add_child(root)
	var wood := _mat("#5a3b28")
	var cloth := _mat("#7a3f42")
	for x in [-2.2, 2.2]:
		_box(Vector3(0.22, 2.8, 0.22), Vector3(x, 1.4, 0), wood, root)
	_box(Vector3(5.0, 0.22, 2.6), Vector3(0, 1.2, 0), wood, root)
	_box(Vector3(5.3, 0.18, 2.9), Vector3(0, 3.0, 0), cloth, root)

func _make_fence(pos: Vector3, length: float) -> void:
	var root := Node3D.new()
	root.position = pos
	add_child(root)
	var wood := _mat("#60432d")
	var count := int(length / 2.5)
	for i in range(count + 1):
		var x := -length * 0.5 + float(i) * 2.5
		_box(Vector3(0.16, 1.5, 0.16), Vector3(x, 0.75, 0), wood, root)
	for y in [0.55, 1.15]:
		_box(Vector3(length, 0.14, 0.14), Vector3(0, y, 0), wood, root)
