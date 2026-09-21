extends Node

## V0.2 animation adapter.
## It is intentionally asset-agnostic: when a real Quaternius character
## is assigned, this controller can drive an AnimationPlayer without changing
## gameplay code.

@export var animation_player_path: NodePath
@export var idle_animation := "idle"
@export var walk_animation := "walk"
@export var run_animation := "run"
@export var jump_animation := "jump"
@export var attack_animation := "attack"

var animation_player: AnimationPlayer

func _ready() -> void:
	if animation_player_path != NodePath():
		animation_player = get_node_or_null(animation_player_path) as AnimationPlayer

func update_state(speed: float, grounded: bool, sprinting: bool, attacking: bool) -> void:
	if animation_player == null:
		return
	var target := idle_animation
	if attacking:
		target = attack_animation
	elif not grounded:
		target = jump_animation
	elif speed > 0.1:
		target = run_animation if sprinting else walk_animation
	if animation_player.has_animation(target) and animation_player.current_animation != target:
		animation_player.play(target)
