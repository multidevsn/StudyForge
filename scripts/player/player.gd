extends CharacterBody3D

@export var walk_speed := 5.5
@export var sprint_speed := 9.0
@export var acceleration := 16.0
@export var jump_velocity := 7.5
@export var gravity := 20.0
@export var mouse_sensitivity := 0.0025
@export var max_health := 100
@export var attack_damage := 25
@export var attack_range := 3.0

@onready var pivot: Node3D = $CameraPivot
@onready var visual: MeshInstance3D = $Visual
@onready var animation_controller: Node = $AnimationController

var camera_pitch := -0.18
var attacking := false
var attack_time := 0.0
var health := 100
var stamina := 100.0

func _ready() -> void:
	add_to_group("player")
	health = max_health
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera_pitch = clamp(camera_pitch - event.relative.y * mouse_sensitivity, -1.05, 0.55)
		pivot.rotation.x = camera_pitch
	elif event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		attack()

func _physics_process(delta: float) -> void:
	var input_vec := Vector2.ZERO
	if Input.is_physical_key_pressed(KEY_A): input_vec.x -= 1.0
	if Input.is_physical_key_pressed(KEY_D): input_vec.x += 1.0
	if Input.is_physical_key_pressed(KEY_W): input_vec.y -= 1.0
	if Input.is_physical_key_pressed(KEY_S): input_vec.y += 1.0
	input_vec = input_vec.normalized()
	var direction := global_transform.basis * Vector3(input_vec.x, 0.0, input_vec.y)
	direction.y = 0.0
	direction = direction.normalized()
	var sprinting := Input.is_physical_key_pressed(KEY_SHIFT) and stamina > 0.0
	var target_speed := sprint_speed if sprinting else walk_speed
	var target_velocity := direction * target_speed
	velocity.x = move_toward(velocity.x, target_velocity.x, acceleration * delta)
	velocity.z = move_toward(velocity.z, target_velocity.z, acceleration * delta)
	if sprinting and direction.length_squared() > 0.01:
		stamina = max(stamina - 24.0 * delta, 0.0)
	else:
		stamina = min(stamina + 16.0 * delta, 100.0)
	if not is_on_floor():
		velocity.y -= gravity * delta
	elif Input.is_physical_key_pressed(KEY_SPACE):
		velocity.y = jump_velocity
	if direction.length_squared() > 0.01:
		visual.rotation.y = lerp_angle(visual.rotation.y, atan2(direction.x, direction.z), delta * 10.0)
	if attack_time > 0.0:
		attack_time -= delta
		visual.scale = Vector3.ONE * (1.0 + sin((0.25 - attack_time) * 20.0) * 0.06)
	else:
		visual.scale = Vector3.ONE
	move_and_slide()
	if animation_controller and animation_controller.has_method("update_state"):
		animation_controller.update_state(Vector2(velocity.x, velocity.z).length(), is_on_floor(), sprinting, attacking)

func attack() -> void:
	if attacking:
		return
	attacking = true
	attack_time = 0.25
	var audio := get_tree().get_first_node_in_group("audio_manager")
	if audio:
		audio.play_sfx("attack")
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy):
			continue
		var to_enemy := enemy.global_position - global_position
		var flat := Vector3(to_enemy.x, 0.0, to_enemy.z)
		if flat.length() <= attack_range:
			var forward := -global_transform.basis.z
			if forward.dot(flat.normalized()) > 0.15 and enemy.has_method("take_damage"):
				enemy.take_damage(attack_damage)
	await get_tree().create_timer(0.25).timeout
	attacking = false

func take_damage(amount: int) -> void:
	health = max(health - amount, 0)
	var audio := get_tree().get_first_node_in_group("audio_manager")
	if audio:
		audio.play_sfx("hit")
	if health <= 0:
		health = max_health
		global_position = Vector3(0, 3, 8)
	var hud := get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("show_message"):
		hud.show_message("Tu subis %d dégâts." % amount)
