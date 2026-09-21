extends StaticBody3D
var shop_open := false
var cooldown := 0.0

func _ready() -> void:
	add_to_group("merchants")

func _process(delta: float) -> void:
	cooldown = max(cooldown - delta, 0.0)
	var player := get_tree().get_first_node_in_group("player")
	var rpg := get_tree().get_first_node_in_group("rpg_system")
	var hud := get_tree().get_first_node_in_group("hud")
	if player == null or rpg == null or hud == null: return
	if global_position.distance_to(player.global_position) <= 3.5:
		if Input.is_key_pressed(KEY_E) and cooldown <= 0.0:
			cooldown = 0.7
			shop_open = true
			hud.show_message("MARCHAND — 1 Potion (15 or) | 2 Épée de fer (60 or) | U équiper | Or: %d" % rpg.gold)
		if shop_open and Input.is_key_pressed(KEY_1) and cooldown <= 0.0:
			cooldown = 0.25
			if rpg.buy("potion",15): hud.show_message("Potion achetée. Or: %d" % rpg.gold)
			else: hud.show_message("Pas assez d'or.")
		elif shop_open and Input.is_key_pressed(KEY_2) and cooldown <= 0.0:
			cooldown = 0.25
			if rpg.buy("iron_sword",60): hud.show_message("Épée achetée. Or: %d" % rpg.gold)
			else: hud.show_message("Pas assez d'or.")
	else:
		shop_open = false
