extends StaticBody3D

@export_multiline var dialogue := "Bienvenue à ECLYRIA. Les ombres se réveillent dans la forêt."

var player_in_range := false

func _ready() -> void:
	add_to_group("npcs")

func _physics_process(_delta: float) -> void:
	if player_in_range and Input.is_key_pressed(KEY_E):
		var hud := get_tree().get_first_node_in_group("hud")
		if hud and hud.has_method("show_message"):
			hud.show_message(dialogue)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_in_range = true

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
