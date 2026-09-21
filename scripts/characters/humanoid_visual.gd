extends Node3D

@export var role := "villager"
@export var skin_color := Color("#c98d67")
@export var outfit_color := Color("#3b5876")
@export var accent_color := Color("#c7a15a")
@export var scale_factor := 1.0

func _ready() -> void:
	_build()

func _mat(color: Color, roughness := 0.78, metallic := 0.0) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = roughness
	mat.metallic = metallic
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

	var skin := _mat(skin_color, 0.9)
	var cloth := _mat(outfit_color, 0.88)
	var accent := _mat(accent_color, 0.65, 0.05)
	var dark := _mat(Color("#211d24"), 0.72)

	var torso := CapsuleMesh.new()
	torso.radius = 0.34
	torso.height = 0.9
	_mesh(body, torso, Vector3(0, 1.18, 0), Vector3.ONE, cloth)

	var head := SphereMesh.new()
	head.radius = 0.28
	head.height = 0.56
	_mesh(body, head, Vector3(0, 1.88, 0), Vector3.ONE, skin)

	var hair := SphereMesh.new()
	hair.radius = 0.29
	hair.height = 0.32
	_mesh(body, hair, Vector3(0, 2.05, 0), Vector3(1.0, 0.75, 1.0), dark)

	var arm := CapsuleMesh.new()
	arm.radius = 0.11
	arm.height = 0.72
	var left_arm := _mesh(body, arm, Vector3(-0.43, 1.25, 0), Vector3.ONE, cloth)
	left_arm.rotation.z = -0.18
	var right_arm := _mesh(body, arm, Vector3(0.43, 1.25, 0), Vector3.ONE, cloth)
	right_arm.rotation.z = 0.18

	var leg := CapsuleMesh.new()
	leg.radius = 0.13
	leg.height = 0.82
	_mesh(body, leg, Vector3(-0.18, 0.48, 0), Vector3.ONE, dark)
	_mesh(body, leg, Vector3(0.18, 0.48, 0), Vector3.ONE, dark)

	var belt := CylinderMesh.new()
	belt.top_radius = 0.37
	belt.bottom_radius = 0.37
	belt.height = 0.12
	_mesh(body, belt, Vector3(0, 0.93, 0), Vector3.ONE, accent)

	var eye := SphereMesh.new()
	eye.radius = 0.045
	eye.height = 0.09
	_mesh(body, eye, Vector3(-0.105, 1.9, -0.255), Vector3.ONE, dark)
	_mesh(body, eye, Vector3(0.105, 1.9, -0.255), Vector3.ONE, dark)

	match role:
		"guard":
			var helmet := CylinderMesh.new()
			helmet.top_radius = 0.28
			helmet.bottom_radius = 0.34
			helmet.height = 0.18
			_mesh(body, helmet, Vector3(0, 2.13, 0), Vector3.ONE, accent)
			var shield := BoxMesh.new()
			shield.size = Vector3(0.5, 0.72, 0.12)
			_mesh(body, shield, Vector3(-0.5, 1.18, -0.08), Vector3.ONE, accent)
		"merchant":
			var pack := BoxMesh.new()
			pack.size = Vector3(0.46, 0.55, 0.28)
			_mesh(body, pack, Vector3(0, 1.25, 0.26), Vector3.ONE, accent)
			var hood := SphereMesh.new()
			hood.radius = 0.31
			hood.height = 0.38
			_mesh(body, hood, Vector3(0, 2.04, 0), Vector3.ONE, outfit_color)
		"elder":
			var staff := CylinderMesh.new()
			staff.top_radius = 0.035
			staff.bottom_radius = 0.05
			staff.height = 1.45
			_mesh(body, staff, Vector3(0.48, 0.9, 0.0), Vector3.ONE, dark)
		"adventurer":
			var cloak := BoxMesh.new()
			cloak.size = Vector3(0.55, 0.85, 0.12)
			_mesh(body, cloak, Vector3(0, 1.23, 0.31), Vector3.ONE, accent)
		_:
			var apron := BoxMesh.new()
			apron.size = Vector3(0.46, 0.55, 0.08)
			_mesh(body, apron, Vector3(0, 1.22, -0.31), Vector3.ONE, accent)
