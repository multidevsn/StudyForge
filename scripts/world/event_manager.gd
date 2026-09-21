extends Node

var timer := 0.0
var event_index := 0

func _ready() -> void:
	add_to_group("event_manager")

func _process(delta: float) -> void:
	timer += delta
	if timer < 45.0: return
	timer = 0.0
	event_index += 1
	_trigger_event()

func _trigger_event() -> void:
	var player := get_tree().get_first_node_in_group("player")
	var hud := get_tree().get_first_node_in_group("hud")
	if hud == null: return
	match event_index % 3:
		0:
			hud.show_message("ÉVÉNEMENT — Des ombres approchent du village !")
			if player:
				var enemy := preload("res://scenes/enemies/Enemy.tscn").instantiate()
				enemy.position = player.global_position + Vector3(8, 0, -8)
				get_parent().add_child(enemy)
		1:
			hud.show_message("ÉVÉNEMENT — Une caravane traverse la vallée.")
		2:
			hud.show_message("ÉVÉNEMENT — Une ancienne relique a été repérée dans les ruines.")
