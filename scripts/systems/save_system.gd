extends Node

const SAVE_PATH := "user://eclyria_save.json"

func save_game(player: Node3D, world: Node) -> bool:
	if player == null:
		return false
	var rpg := get_tree().get_first_node_in_group("rpg_system")
	var data := {
		"version": 3,
		"player": {
			"position": [player.global_position.x, player.global_position.y, player.global_position.z],
			"rotation_y": player.rotation.y,
			"hp": player.health,
			"stamina": player.stamina
		},
		"time_of_day": world.time_of_day if world else 8.0,
		"rpg": {
			"inventory": rpg.inventory if rpg else {},
			"equipment": rpg.equipment if rpg else {},
			"gold": rpg.gold if rpg else 0,
			"xp": rpg.xp if rpg else 0,
			"level": rpg.level if rpg else 1,
			"skill_points": rpg.skill_points if rpg else 0,
			"skills": rpg.skills if rpg else {},
			"quests": rpg.quests if rpg else {}
		},
		"world": world.serialize_world_state() if world and world.has_method("serialize_world_state") else {}
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
	var saved_player: Dictionary = parsed.get("player", {})
	var p: Array = saved_player.get("position", [0.0, 3.0, 8.0])
	player.global_position = Vector3(float(p[0]), float(p[1]), float(p[2]))
	player.rotation.y = float(saved_player.get("rotation_y", 0.0))
	player.health = int(saved_player.get("hp", player.health))
	player.stamina = float(saved_player.get("stamina", player.stamina))
	if world:
		world.time_of_day = float(parsed.get("time_of_day", 8.0))
	var rpg := get_tree().get_first_node_in_group("rpg_system")
	var saved: Dictionary = parsed.get("rpg", {})
	if rpg and not saved.is_empty():
		rpg.inventory = saved.get("inventory", rpg.inventory)
		rpg.equipment = saved.get("equipment", rpg.equipment)
		rpg.gold = int(saved.get("gold", rpg.gold))
		rpg.xp = int(saved.get("xp", rpg.xp))
		rpg.level = int(saved.get("level", rpg.level))
		rpg.skill_points = int(saved.get("skill_points", rpg.skill_points))
		rpg.skills = saved.get("skills", rpg.skills)
		rpg.quests = saved.get("quests", rpg.quests)
		rpg._update_player()
	if world and world.has_method("restore_world_state"):
		world.restore_world_state(parsed.get("world", {}))
	return true
