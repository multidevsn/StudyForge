extends Node

const SAVE_PATH: String = "user://eclyria_save.json"

func save_game(player: Node3D, world: Node) -> bool:
	if player == null:
		return false

	var rpg = get_tree().get_first_node_in_group("rpg_system")
	var world_state: Dictionary = {}
	if world != null and world.has_method("serialize_world_state"):
		var serialized = world.call("serialize_world_state")
		if serialized is Dictionary:
			world_state = serialized

	var data: Dictionary = {
		"version": 3,
		"player": {
			"position": [player.global_position.x, player.global_position.y, player.global_position.z],
			"rotation_y": player.rotation.y,
			"hp": int(player.get("health")),
			"stamina": float(player.get("stamina"))
		},
		"time_of_day": float(world.get("time_of_day")) if world != null else 8.0,
		"rpg": {
			"inventory": rpg.get("inventory") if rpg != null else {},
			"equipment": rpg.get("equipment") if rpg != null else {},
			"gold": int(rpg.get("gold")) if rpg != null else 0,
			"xp": int(rpg.get("xp")) if rpg != null else 0,
			"level": int(rpg.get("level")) if rpg != null else 1,
			"skill_points": int(rpg.get("skill_points")) if rpg != null else 0,
			"skills": rpg.get("skills") if rpg != null else {},
			"quests": rpg.get("quests") if rpg != null else {}
		},
		"world": world_state
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
	var position_data = saved_player.get("position", [0.0, 3.0, 8.0])
	if position_data is Array and position_data.size() >= 3:
		var p: Array = position_data
		player.global_position = Vector3(float(p[0]), float(p[1]), float(p[2]))

	player.rotation.y = float(saved_player.get("rotation_y", 0.0))
	var saved_hp = saved_player.get("hp", player.get("health"))
	var saved_stamina = saved_player.get("stamina", player.get("stamina"))
	player.set("health", int(saved_hp))
	player.set("stamina", float(saved_stamina))

	if world != null:
		world.set("time_of_day", float(parsed.get("time_of_day", 8.0)))

	var rpg = get_tree().get_first_node_in_group("rpg_system")
	var saved: Dictionary = parsed.get("rpg", {})
	if rpg != null and not saved.is_empty():
		rpg.set("inventory", saved.get("inventory", rpg.get("inventory")))
		rpg.set("equipment", saved.get("equipment", rpg.get("equipment")))
		rpg.set("gold", int(saved.get("gold", rpg.get("gold"))))
		rpg.set("xp", int(saved.get("xp", rpg.get("xp"))))
		rpg.set("level", int(saved.get("level", rpg.get("level"))))
		rpg.set("skill_points", int(saved.get("skill_points", rpg.get("skill_points"))))
		rpg.set("skills", saved.get("skills", rpg.get("skills")))
		rpg.set("quests", saved.get("quests", rpg.get("quests")))
		if rpg.has_method("_update_player"):
			rpg.call("_update_player")

	if world != null and world.has_method("restore_world_state"):
		world.call("restore_world_state", parsed.get("world", {}))

	return true
