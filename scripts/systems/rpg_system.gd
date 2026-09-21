extends Node

signal stats_changed
signal inventory_changed
signal quest_changed

var inventory: Dictionary = {
	"potion": 2,
	"iron_sword": 1
}
var equipment: Dictionary = {
	"weapon": "iron_sword",
	"armor": ""
}
var gold := 50
var xp := 0
var level := 1
var skill_points := 0
var skills: Dictionary = {
	"power": 0,
	"vitality": 0,
	"agility": 0
}
var quests: Dictionary = {
	"first_blood": {"title":"Premier sang", "type":"kill", "target":"enemy", "goal":1, "progress":0, "reward_xp":100, "reward_gold":40, "started":false, "completed":false},
	"lost_relic": {"title":"La relique perdue", "type":"collect", "target":"ancient_relic", "goal":1, "progress":0, "reward_xp":160, "reward_gold":75, "started":false, "completed":false},
	"village_request": {"title":"Une faveur du village", "type":"talk", "target":"elder", "goal":1, "progress":0, "reward_xp":80, "reward_gold":25, "started":false, "completed":false}
}

func _ready() -> void:
	add_to_group("rpg_system")

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	var hud = get_tree().get_first_node_in_group("hud")
	if event.keycode == KEY_I:
		if hud: hud.show_message(inventory_text())
	elif event.keycode == KEY_K:
		if hud: hud.show_message(skills_text())
	elif event.keycode == KEY_U:
		equip_item("iron_sword")
	elif event.keycode == KEY_1:
		spend_skill("power")
	elif event.keycode == KEY_2:
		spend_skill("vitality")
	elif event.keycode == KEY_3:
		spend_skill("agility")

func add_item(item_id: String, amount: int = 1) -> void:
	inventory[item_id] = int(inventory.get(item_id, 0)) + amount
	inventory_changed.emit()
	_update_player()
	var audio = get_tree().get_first_node_in_group("audio_manager")
	if audio:
		audio.play_sfx("pickup")

func remove_item(item_id: String, amount: int = 1) -> bool:
	if int(inventory.get(item_id, 0)) < amount:
		return false
	inventory[item_id] = int(inventory[item_id]) - amount
	if inventory[item_id] <= 0:
		inventory.erase(item_id)
	inventory_changed.emit()
	return true

func equip_item(item_id: String) -> bool:
	if int(inventory.get(item_id, 0)) <= 0:
		return false
	equipment["weapon"] = item_id
	_update_player()
	var hud = get_tree().get_first_node_in_group("hud")
	if hud: hud.show_message("Équipé : %s" % item_name(item_id))
	return true

func add_xp(amount: int) -> void:
	xp += amount
	while xp >= xp_to_next_level():
		xp -= xp_to_next_level()
		level += 1
		skill_points += 1
		var hud = get_tree().get_first_node_in_group("hud")
		if hud: hud.show_message("NIVEAU %d ! +1 point de compétence." % level)
	stats_changed.emit()
	_update_player()

func xp_to_next_level() -> int:
	return 100 + (level - 1) * 75

func spend_skill(skill_id: String) -> bool:
	if skill_points <= 0 or not skills.has(skill_id):
		return false
	skill_points -= 1
	skills[skill_id] += 1
	_update_player()
	var hud = get_tree().get_first_node_in_group("hud")
	if hud: hud.show_message("Compétence %s améliorée (%d)." % [skill_id, skills[skill_id]])
	return true

func _update_player() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	player.max_health = 100 + skills["vitality"] * 15
	player.attack_damage = 25 + skills["power"] * 5
	player.walk_speed = 5.5 + skills["agility"] * 0.35
	player.sprint_speed = 9.0 + skills["agility"] * 0.45
	if player.health > player.max_health:
		player.health = player.max_health

func register_enemy_defeat() -> void:
	add_xp(35)
	gold += 10
	if int(quests["first_blood"]["started"]) and not quests["first_blood"]["completed"]:
		_progress_quest("first_blood", 1)
	# First kill guarantees a useful drop; later kills use a small random table.
	if int(quests["first_blood"]["progress"]) == 1:
		add_item("iron_sword", 1)
		add_item("potion", 1)
	else:
		var roll := randi() % 100
		if roll < 55: add_item("potion", 1)
		elif roll < 75: add_item("iron_sword", 1)
		else:
			add_item("ancient_relic", 1)
			register_event("collect", "ancient_relic", 1)

func start_quest(id: String) -> void:
	if not quests.has(id): return
	quests[id]["started"] = true
	quest_changed.emit()
	var hud = get_tree().get_first_node_in_group("hud")
	if hud: hud.show_message("Quête : %s" % quests[id]["title"])

func register_event(event_type: String, target: String, amount: int = 1) -> void:
	for id in quests.keys():
		var q: Dictionary = quests[id]
		if q["started"] and not q["completed"] and q["type"] == event_type and q["target"] == target:
			_progress_quest(id, amount)

func _progress_quest(id: String, amount: int) -> void:
	quests[id]["progress"] = min(int(quests[id]["progress"]) + amount, int(quests[id]["goal"]))
	if int(quests[id]["progress"]) >= int(quests[id]["goal"]):
		quests[id]["completed"] = true
		add_xp(int(quests[id]["reward_xp"]))
		gold += int(quests[id]["reward_gold"])
		var hud = get_tree().get_first_node_in_group("hud")
		if hud: hud.show_message("Quête terminée : %s (+%d XP, +%d or)." % [quests[id]["title"], quests[id]["reward_xp"], quests[id]["reward_gold"]])
		if id == "first_blood": start_quest("lost_relic")
	quest_changed.emit()

func buy(item_id: String, price: int) -> bool:
	if gold < price: return false
	gold -= price
	add_item(item_id, 1)
	return true

func inventory_text() -> String:
	var lines := ["INVENTAIRE", "Or : %d" % gold, "Arme : %s" % item_name(equipment["weapon"])]
	for id in inventory.keys():
		lines.append("- %s x%d" % [item_name(id), inventory[id]])
	return "\n".join(lines)

func skills_text() -> String:
	return "COMPÉTENCES\nPoints : %d\n1 Puissance : %d\n2 Vitalité : %d\n3 Agilité : %d" % [skill_points, skills["power"], skills["vitality"], skills["agility"]]

func quests_text() -> String:
	var lines := ["QUÊTES"]
	for id in quests.keys():
		var q: Dictionary = quests[id]
		if q["started"]:
			lines.append("%s : %d/%d%s" % [q["title"], q["progress"], q["goal"], " ✓" if q["completed"] else ""])
	return "\n".join(lines)

func item_name(id: String) -> String:
	match id:
		"potion": return "Potion"
		"iron_sword": return "Épée de fer"
		"ancient_relic": return "Relique ancienne"
		_: return id
