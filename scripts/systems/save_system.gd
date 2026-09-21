extends Node

const SAVE_PATH := "user://eclyria_save.json"

func save_game(player: Node3D, world: Node) -> bool:
	if player == null:
		return false
	var data := {
		"version": 1,
		"player_position": [player.global_position.x, player.global_position.y, player.global_position.z],
		"player_rotation_y": player.rotation.y,
		"player_hp": player.get("health") if player.get("health") != null else 100,
		"time_of_day": world.time_of_day if world != null else 8.0
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(data))
	return true

func load_game(player: Node3D, world: Node) -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return false
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return false
	var p: Array = parsed.get("player_position", [0.0, 1.0, 8.0])
	player.global_position = Vector3(float(p[0]), float(p[1]), float(p[2]))
	player.rotation.y = float(parsed.get("player_rotation_y", 0.0))
	if player.get("health") != null:
		player.set("health", int(parsed.get("player_hp", 100)))
	if world != null:
		world.time_of_day = float(parsed.get("time_of_day", 8.0))
	return true
