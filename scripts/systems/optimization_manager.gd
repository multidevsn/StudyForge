extends Node

@export var target_fps := 60
@export var far_cull_distance := 90.0
var last_frame_check := 0.0

func _ready() -> void:
	add_to_group("optimization_manager")
	Engine.max_fps = target_fps

func _process(delta: float) -> void:
	last_frame_check += delta
	if last_frame_check < 2.0:
		return
	last_frame_check = 0.0
	var player := get_tree().get_first_node_in_group("player")
	if player == null:
		return
	for node in get_tree().get_nodes_in_group("stream_optimized"):
		if not is_instance_valid(node):
			continue
		var distance := node.global_position.distance_to(player.global_position)
		node.visible = distance <= far_cull_distance
