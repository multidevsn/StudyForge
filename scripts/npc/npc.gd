extends StaticBody3D
var cooldown := 0.0
var line_index := 0
var lines := ["Bienvenue à ECLYRIA. Les ombres se réveillent dans la forêt.","Un monstre rôde dans la vallée. Élimine-le et reviens me voir.","Les ruines au nord cachent une relique ancienne."]

func _ready() -> void:
	add_to_group("npcs")

func _process(delta: float) -> void:
	cooldown = max(cooldown - delta, 0.0)
	var player: Node3D = get_tree().get_first_node_in_group("player") as Node3D
	if player == null or cooldown > 0.0: return
	if global_position.distance_to(player.global_position) <= 3.0 and Input.is_key_pressed(KEY_E):
		cooldown = 0.7
		var rpg := get_tree().get_first_node_in_group("rpg_system")
		var hud := get_tree().get_first_node_in_group("hud")
		if hud: hud.show_message(lines[line_index % lines.size()])
		line_index += 1
		if rpg:
			rpg.start_quest("first_blood")
			rpg.start_quest("village_request")
			rpg.register_event("talk","elder",1)
