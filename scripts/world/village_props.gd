extends Node3D

## V0.2 visual pass: extra village landmarks while external asset packs
## are being integrated. These are procedural placeholders, not reused assets.

func _ready() -> void:
	_make_well(Vector3(-8, 0, -10))
	_make_market(Vector3(2, 0, -2))
	_make_fence(Vector3(-22, 0, -10), 18.0)
	_make_lamps()
	_make_carts()
	_make_barrels_and_crates()
	_make_campfires()

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


func _make_lamps() -> void:
	var metal := _mat("#24232a")
	var glow := _mat("#d9a95d", 0.35, 0.0)
	for pos in [
		Vector3(-19, 0, -15), Vector3(-7, 0, -15), Vector3(4, 0, -11),
		Vector3(12, 0, -2), Vector3(12, 0, 11), Vector3(-17, 0, 12)
	]:
		var root := Node3D.new()
		root.position = pos
		add_child(root)
		_box(Vector3(0.12, 2.8, 0.12), Vector3(0, 1.4, 0), metal, root)
		var cap := CylinderMesh.new()
		cap.top_radius = 0.22
		cap.bottom_radius = 0.16
		cap.height = 0.18
		_mesh_prop(root, cap, Vector3(0, 2.75, 0), glow)

func _make_carts() -> void:
	var wood := _mat("#5b3e2a")
	var metal := _mat("#29272a")
	for pos in [Vector3(-15, 0, -1), Vector3(10, 0, 4)]:
		var root := Node3D.new()
		root.position = pos
		add_child(root)
		_box(Vector3(2.8, 0.22, 1.4), Vector3(0, 0.7, 0), wood, root)
		_box(Vector3(0.18, 1.0, 0.18), Vector3(-1.0, 1.15, 0.45), wood, root)
		_box(Vector3(0.18, 1.0, 0.18), Vector3(1.0, 1.15, 0.45), wood, root)
		for x in [-1.05, 1.05]:
			var wheel := CylinderMesh.new()
			wheel.top_radius = 0.38
			wheel.bottom_radius = 0.38
			wheel.height = 0.14
			var node := _mesh_prop(root, wheel, Vector3(x, 0.38, -0.72), metal)
			node.rotation_degrees.x = 90.0

func _make_barrels_and_crates() -> void:
	var wood := _mat("#66452f")
	var rope := _mat("#b7925e")
	var spots: Array[Vector3] = [
		Vector3(-19, 0, -3), Vector3(-20, 0, -4), Vector3(-3, 0, -4),
		Vector3(8, 0, 14), Vector3(18, 0, 7), Vector3(-15, 0, 16)
	]
	for p in spots:
		var barrel := CylinderMesh.new()
		barrel.top_radius = 0.38
		barrel.bottom_radius = 0.43
		barrel.height = 0.8
		_mesh_prop(self, barrel, p + Vector3(0, 0.4, 0), wood)
		for y in [0.2, 0.6]:
			var ring := TorusMesh.new()
			ring.inner_radius = 0.39
			ring.outer_radius = 0.43
			ring.rings = 8
			ring.ring_segments = 6
			_mesh_prop(self, ring, p + Vector3(0, y, 0), rope)
	for p in [Vector3(-18,0,6), Vector3(4,0,13), Vector3(15,0,-8), Vector3(-5,0,17)]:
		_box(Vector3(0.9, 0.9, 0.9), p + Vector3(0,0.45,0), wood)

func _make_campfires() -> void:
	var dark := _mat("#3a2820")
	var coal := _mat("#242126")
	for pos in [Vector3(-1,0,6), Vector3(15,0,1), Vector3(-24,0,-1)]:
		var root := Node3D.new()
		root.position = pos
		add_child(root)
		for i in range(6):
			var a := TAU * float(i) / 6.0
			var stone_pos := Vector3(cos(a) * 0.7, 0.18, sin(a) * 0.7)
			_box(Vector3(0.35, 0.35, 0.35), stone_pos, dark, root)
		_box(Vector3(0.9, 0.15, 0.9), Vector3(0, 0.33, 0), coal, root)

func _mesh_prop(parent: Node3D, primitive: Mesh, pos: Vector3, material: Material) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.mesh = primitive
	node.position = pos
	node.material_override = material
	parent.add_child(node)
	return node
