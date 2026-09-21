extends Node3D

@export var variant := "goblin"
@export var scale_factor := 1.0
@export var body_color := Color("#5b8a45")
@export var accent_color := Color("#7b3f56")

func _ready() -> void:
	_configure_colors()
	_build()

func set_variant(new_variant: String) -> void:
	variant = new_variant
	_configure_colors()
	for child in get_children():
		child.free()
	_build()

func _configure_colors() -> void:
	match variant:
		"orc":
			body_color = Color("#4e6f55")
			accent_color = Color("#8b633d")
		"demon":
			body_color = Color("#56365f")
			accent_color = Color("#d36a55")
		_:
			body_color = Color("#5b8a45")
			accent_color = Color("#7b3f56")

func _mat(color: Color, roughness := 0.82) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = roughness
	return mat

func _mesh(parent: Node3D, primitive: Mesh, pos: Vector3, scale: Vector3, material: Material) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.mesh = primitive
	node.position = pos
	node.scale = scale
	node.material_override = material
	parent.add_child(node)
	return node

func _build() -> void:
	var body := Node3D.new()
	body.scale = Vector3.ONE * scale_factor
	add_child(body)

	var skin := _mat(body_color)
	var armor := _mat(accent_color)
	var dark := _mat(Color("#1a1218"), 0.68)
	var eyes := _mat(Color("#f0ae35"), 0.3)

	var torso := CapsuleMesh.new()
	torso.radius = 0.43
	torso.height = 1.0
	_mesh(body, torso, Vector3(0, 1.0, 0), Vector3(1.05, 1.0, 0.9), skin)

	var head := SphereMesh.new()
	head.radius = 0.42
	head.height = 0.78
	_mesh(body, head, Vector3(0, 1.82, -0.04), Vector3(1.0, 0.92, 0.9), skin)

	var arm := CapsuleMesh.new()
	arm.radius = 0.14
	arm.height = 0.9
	var left_arm := _mesh(body, arm, Vector3(-0.56, 1.0, 0), Vector3.ONE, armor)
	left_arm.rotation.z = -0.18
	var right_arm := _mesh(body, arm, Vector3(0.56, 1.0, 0), Vector3.ONE, armor)
	right_arm.rotation.z = 0.18

	var leg := CapsuleMesh.new()
	leg.radius = 0.16
	leg.height = 0.95
	_mesh(body, leg, Vector3(-0.2, 0.38, 0), Vector3.ONE, dark)
	_mesh(body, leg, Vector3(0.2, 0.38, 0), Vector3.ONE, dark)

	var eye := SphereMesh.new()
	eye.radius = 0.07
	eye.height = 0.14
	_mesh(body, eye, Vector3(-0.15, 1.84, -0.37), Vector3.ONE, eyes)
	_mesh(body, eye, Vector3(0.15, 1.84, -0.37), Vector3.ONE, eyes)

	var horn := CylinderMesh.new()
	horn.top_radius = 0.015
	horn.bottom_radius = 0.10
	horn.height = 0.36
	_mesh(body, horn, Vector3(-0.25, 2.18, 0), Vector3.ONE, armor)
	_mesh(body, horn, Vector3(0.25, 2.18, 0), Vector3.ONE, armor)

	if variant == "demon":
		var crown := TorusMesh.new()
		crown.inner_radius = 0.24
		crown.outer_radius = 0.34
		crown.rings = 12
		crown.ring_segments = 8
		_mesh(body, crown, Vector3(0, 2.18, 0), Vector3.ONE, armor)
