extends StaticBody3D

@export_multiline var dialogue := "Bienvenue à ECLYRIA. Les ombres se réveillent dans la forêt."

func _ready() -> void:
	add_to_group("npcs")

func _physics_process(_delta: float) -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player == null:
		return
	if global_position.distance_to(player.global_position) <= 3.0 and Input.is_key_pressed(KEY_E):
		var hud := get_tree().get_first_node_in_group("hud")
		if hud and hud.has_method("show_message"):
			hud.show_message(dialogue)
