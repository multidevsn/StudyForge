extends Node3D

@export var tint: Color = Color.WHITE

func _ready() -> void:
	for node in find_children("*", "MeshInstance3D", true, false):
		if node is MeshInstance3D:
			var mesh_node: MeshInstance3D = node as MeshInstance3D
			var active: Material = mesh_node.get_active_material(0)
			if active is StandardMaterial3D:
				var material: StandardMaterial3D = active.duplicate() as StandardMaterial3D
				if material != null:
					material.albedo_color = material.albedo_color * tint
					mesh_node.material_override = material
