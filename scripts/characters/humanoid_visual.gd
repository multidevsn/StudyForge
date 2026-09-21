extends Node3D

@export var role: String = "villager"
@export var skin_color: Color = Color(0.79, 0.55, 0.42, 1.0)
@export var outfit_color: Color = Color(0.23, 0.34, 0.47, 1.0)
@export var accent_color: Color = Color(0.67, 0.50, 0.24, 1.0)
@export var scale_factor: float = 1.0

func _ready() -> void:
	_build()

func _mat(color: Color, roughness: float = 0.78, metallic: float = 0.0) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	material.metallic = metallic
	return material

func _add_mesh(parent: Node3D, mesh: Mesh, position: Vector3, node_scale: Vector3, material: Material) -> MeshInstance3D:
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.mesh = mesh
	instance.position = position
	instance.scale = node_scale
	instance.material_override = material
	parent.add_child(instance)
	return instance

func _build() -> void:
	var body: Node3D = Node3D.new()
	body.scale = Vector3.ONE * scale_factor
	add_child(body)

	var skin: StandardMaterial3D = _mat(skin_color, 0.9)
	var cloth: StandardMaterial3D = _mat(outfit_color, 0.88)
	var accent: StandardMaterial3D = _mat(accent_color, 0.65, 0.05)
	var dark: StandardMaterial3D = _mat(Color(0.13, 0.11, 0.14, 1.0), 0.72)

	var torso: CapsuleMesh = CapsuleMesh.new()
	torso.radius = 0.34
	torso.height = 0.9
	_add_mesh(body, torso, Vector3(0.0, 1.18, 0.0), Vector3.ONE, cloth)

	var head: SphereMesh = SphereMesh.new()
	head.radius = 0.28
	head.height = 0.56
	_add_mesh(body, head, Vector3(0.0, 1.88, 0.0), Vector3.ONE, skin)

	var hair: SphereMesh = SphereMesh.new()
	hair.radius = 0.29
	hair.height = 0.32
	_add_mesh(body, hair, Vector3(0.0, 2.05, 0.0), Vector3(1.0, 0.75, 1.0), dark)

	var arm: CapsuleMesh = CapsuleMesh.new()
	arm.radius = 0.11
	arm.height = 0.72

	var left_arm: MeshInstance3D = _add_mesh(body, arm, Vector3(-0.43, 1.25, 0.0), Vector3.ONE, cloth)
	left_arm.rotation.z = -0.18

	var right_arm: MeshInstance3D = _add_mesh(body, arm, Vector3(0.43, 1.25, 0.0), Vector3.ONE, cloth)
	right_arm.rotation.z = 0.18

	var leg: CapsuleMesh = CapsuleMesh.new()
	leg.radius = 0.13
	leg.height = 0.82
	_add_mesh(body, leg, Vector3(-0.18, 0.48, 0.0), Vector3.ONE, dark)
	_add_mesh(body, leg, Vector3(0.18, 0.48, 0.0), Vector3.ONE, dark)

	var belt: CylinderMesh = CylinderMesh.new()
	belt.top_radius = 0.37
	belt.bottom_radius = 0.37
	belt.height = 0.12
	_add_mesh(body, belt, Vector3(0.0, 0.93, 0.0), Vector3.ONE, accent)

	var eye: SphereMesh = SphereMesh.new()
	eye.radius = 0.045
	eye.height = 0.09
	_add_mesh(body, eye, Vector3(-0.105, 1.90, -0.255), Vector3.ONE, dark)
	_add_mesh(body, eye, Vector3(0.105, 1.90, -0.255), Vector3.ONE, dark)

	if role == "guard":
		var helmet: CylinderMesh = CylinderMesh.new()
		helmet.top_radius = 0.28
		helmet.bottom_radius = 0.34
		helmet.height = 0.18
		_add_mesh(body, helmet, Vector3(0.0, 2.13, 0.0), Vector3.ONE, accent)

		var shield: BoxMesh = BoxMesh.new()
		shield.size = Vector3(0.5, 0.72, 0.12)
		_add_mesh(body, shield, Vector3(-0.5, 1.18, -0.08), Vector3.ONE, accent)

	elif role == "merchant":
		var pack: BoxMesh = BoxMesh.new()
		pack.size = Vector3(0.46, 0.55, 0.28)
		_add_mesh(body, pack, Vector3(0.0, 1.25, 0.26), Vector3.ONE, accent)

		var hood: SphereMesh = SphereMesh.new()
		hood.radius = 0.31
		hood.height = 0.38
		_add_mesh(body, hood, Vector3(0.0, 2.04, 0.0), Vector3.ONE, outfit_color)

	elif role == "elder":
		var staff: CylinderMesh = CylinderMesh.new()
		staff.top_radius = 0.035
		staff.bottom_radius = 0.05
		staff.height = 1.45
		_add_mesh(body, staff, Vector3(0.48, 0.9, 0.0), Vector3.ONE, dark)

	elif role == "adventurer":
		var cloak: BoxMesh = BoxMesh.new()
		cloak.size = Vector3(0.55, 0.85, 0.12)
		_add_mesh(body, cloak, Vector3(0.0, 1.23, 0.31), Vector3.ONE, accent)

	else:
		var apron: BoxMesh = BoxMesh.new()
		apron.size = Vector3(0.46, 0.55, 0.08)
		_add_mesh(body, apron, Vector3(0.0, 1.22, -0.31), Vector3.ONE, accent)
