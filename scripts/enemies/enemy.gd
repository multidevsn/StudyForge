extends CharacterBody3D

@export var max_health := 60
@export var move_speed := 2.6
@export var attack_damage := 8
@export var attack_range := 2.0
@export var detection_range := 16.0
@export var enemy_id := ""

var health := 60
var attack_cooldown := 0.0
var spawn_position := Vector3.ZERO
var target: Node3D
var animation_player: AnimationPlayer

func _ready() -> void:
	add_to_group("enemies")
	health = max_health
	spawn_position = global_position
	var visual: Node = get_node_or_null("Visual")
	if visual:
		var players := visual.find_children("*", "AnimationPlayer", true, false)
		if not players.is_empty():
			animation_player = players[0] as AnimationPlayer

func _physics_process(delta: float) -> void:
	attack_cooldown = max(attack_cooldown - delta, 0.0)
	if target == null:
		target = get_tree().get_first_node_in_group("player")
	if target == null:
		return
	var distance: float = global_position.distance_to(target.global_position)
	if distance <= attack_range:
		_play_animation(["2H_Melee_Attack_Chop", "attack", "attack_1"])
		velocity = Vector3.ZERO
		look_at(Vector3(target.global_position.x, global_position.y, target.global_position.z), Vector3.UP)
		if attack_cooldown <= 0.0:
			attack_cooldown = 1.2
			if target.has_method("take_damage"):
				target.take_damage(attack_damage)
	elif distance <= detection_range:
		_play_animation(["Running_A", "run", "walk"])
		var direction: Vector3 = global_position.direction_to(target.global_position)
		direction.y = 0.0
		velocity = direction.normalized() * move_speed
		look_at(global_position + Vector3(direction.x, 0, direction.z), Vector3.UP)
		move_and_slide()
	else:
		_play_animation(["Idle", "idle"])
		velocity = Vector3.ZERO

func _play_animation(names: Array[String]) -> void:
	if animation_player == null:
		return
	for name in names:
		if animation_player.has_animation(name):
			if animation_player.current_animation != name:
				animation_player.play(name)
			return

func take_damage(amount: int) -> void:
	health = max(health - amount, 0)
	flash_hit()
	if health == 0:
		_die()

func flash_hit() -> void:
	var visual := get_node_or_null("Visual")
	if visual:
		visual.scale = Vector3.ONE * 1.12
		get_tree().create_timer(0.08).timeout.connect(func():
			if is_instance_valid(visual):
				visual.scale = Vector3.ONE
		)

func _die() -> void:
	_play_animation(["Death_A", "death", "die"])
	var audio := get_tree().get_first_node_in_group("audio_manager")
	if audio: audio.play_sfx("hit")
	var world := get_parent()
	if world and world.has_method("on_enemy_defeated"):
		world.on_enemy_defeated(self)
	queue_free()
