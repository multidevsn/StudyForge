extends StaticBody3D

var shop_open := false

func _ready() -> void:
	add_to_group("merchants")

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo: return
	var player: Node3D = get_tree().get_first_node_in_group("player") as Node3D
	var rpg = get_tree().get_first_node_in_group("rpg_system")
	var hud = get_tree().get_first_node_in_group("hud")
	if player == null or rpg == null or hud == null: return
	if global_position.distance_to(player.global_position) > 3.5:
		shop_open = false
		return
	if event.keycode == KEY_E:
		shop_open = true
		hud.show_message("MARCHAND — 1 Potion (15 or) | 2 Épée de fer (60 or) | U équiper | Or: %d" % rpg.gold)
	elif shop_open and event.keycode == KEY_1:
		if rpg.buy("potion",15): hud.show_message("Potion achetée. Or: %d" % rpg.gold)
		else: hud.show_message("Pas assez d'or.")
	elif shop_open and event.keycode == KEY_2:
		if rpg.buy("iron_sword",60): hud.show_message("Épée achetée. Or: %d" % rpg.gold)
		else: hud.show_message("Pas assez d'or.")
