extends CharacterBody3D

@export var max_health := 300
@export var move_speed := 2.2
@export var attack_damage := 18
var health := 300
var cooldown := 0.0
var phase := 1

func _ready() -> void:
	add_to_group("bosses")
	health = max_health

func _physics_process(delta: float) -> void:
	cooldown = max(cooldown - delta, 0.0)
	var player := get_tree().get_first_node_in_group("player")
	if player == null: return
	var d := global_position.distance_to(player.global_position)
	if d > 22.0: return
	if d > 2.5:
		var dir := global_position.direction_to(player.global_position)
		dir.y = 0.0
		velocity = dir.normalized() * move_speed
		move_and_slide()
		look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	elif cooldown <= 0.0:
		cooldown = 1.0 if phase == 1 else 0.65
		if player.has_method("take_damage"):
			player.take_damage(attack_damage)

func take_damage(amount: int) -> void:
	health = max(health - amount, 0)
	if health <= max_health * 0.5 and phase == 1:
		phase = 2
		move_speed = 3.0
		var hud := get_tree().get_first_node_in_group("hud")
		if hud: hud.show_message("BOSS — phase 2 !")
	if health == 0:
		var rpg := get_tree().get_first_node_in_group("rpg_system")
		if rpg:
			rpg.add_xp(300)
			rpg.gold += 250
			rpg.add_item("ancient_relic", 1)
			rpg.register_event("kill", "boss", 1)
		var hud := get_tree().get_first_node_in_group("hud")
		if hud: hud.show_message("GARDIEN VAINCU — butin légendaire obtenu.")
		queue_free()
