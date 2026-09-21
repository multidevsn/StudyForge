extends CharacterBody3D

@export var walk_speed := 5.5
@export var sprint_speed := 9.0
@export var acceleration := 16.0
@export var jump_velocity := 7.5
@export var gravity := 20.0
@export var mouse_sensitivity := 0.0025

@onready var pivot: Node3D = $CameraPivot
@onready var visual: MeshInstance3D = $Visual

var camera_pitch := -0.18
var attacking := false
var attack_time := 0.0

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera_pitch = clamp(camera_pitch - event.relative.y * mouse_sensitivity, -1.05, 0.55)
		pivot.rotation.x = camera_pitch
	elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
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
	var target_speed := sprint_speed if Input.is_physical_key_pressed(KEY_SHIFT) else walk_speed
	var target_velocity := direction * target_speed
	velocity.x = move_toward(velocity.x, target_velocity.x, acceleration * delta)
	velocity.z = move_toward(velocity.z, target_velocity.z, acceleration * delta)

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

func attack() -> void:
	if attacking: return
	attacking = true
	attack_time = 0.25
	await get_tree().create_timer(0.25).timeout
	attacking = false
