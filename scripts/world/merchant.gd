extends Node3D

var cooldown := 0.0

func _ready() -> void:
	add_to_group("merchants")

func _process(delta: float) -> void:
	cooldown = max(cooldown - delta, 0.0)
	var player := get_tree().get_first_node_in_group("player")
	if player == null or cooldown > 0.0:
		return
	if global_position.distance_to(player.global_position) <= 3.5 and Input.is_key_pressed(KEY_E):
		cooldown = 0.6
		var rpg := get_tree().get_first_node_in_group("rpg_system")
		var hud := get_tree().get_first_node_in_group("hud")
		if rpg == null or hud == null: return
		hud.show_message("MARCHAND — 1 Potion (15 or) | 2 Épée de fer (60 or) | Or: %d" % rpg.gold)
		if Input.is_key_pressed(KEY_1):
			if rpg.buy("potion", 15): hud.show_message("Potion achetée.")
			else: hud.show_message("Pas assez d'or.")
		elif Input.is_key_pressed(KEY_2):
			if rpg.buy("iron_sword", 60): hud.show_message("Épée achetée.")
			else: hud.show_message("Pas assez d'or.")
