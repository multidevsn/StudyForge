extends CharacterBody3D

@export var walk_speed := 1.35
@export var patrol_radius := 7.0
@export var role := "villager"

var origin := Vector3.ZERO
var target := Vector3.ZERO
var wait_time := 0.0
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	add_to_group("citizens")
	origin = global_position
	rng.seed = int(get_instance_id() * 97)
	_pick_target()

func _physics_process(delta: float) -> void:
	if wait_time > 0.0:
		wait_time -= delta
		velocity.x = move_toward(velocity.x, 0.0, walk_speed * 4.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, walk_speed * 4.0 * delta)
	else:
		var flat_target: Vector3 = Vector3(target.x, global_position.y, target.z)
		var direction: Vector3 = global_position.direction_to(flat_target)
		direction.y = 0.0
		if direction.length() < 0.35:
			wait_time = rng.randf_range(0.6, 2.4)
			_pick_target()
		else:
			velocity.x = move_toward(velocity.x, direction.x * walk_speed, 5.0 * delta)
			velocity.z = move_toward(velocity.z, direction.z * walk_speed, 5.0 * delta)
			look_at(global_position + Vector3(direction.x, 0, direction.z), Vector3.UP)

	if not is_on_floor():
		velocity.y -= 20.0 * delta
	else:
		velocity.y = 0.0
	move_and_slide()

func _pick_target() -> void:
	var angle := rng.randf_range(0.0, TAU)
	var radius := rng.randf_range(2.0, patrol_radius)
	target = origin + Vector3(cos(angle) * radius, 0.0, sin(angle) * radius)
