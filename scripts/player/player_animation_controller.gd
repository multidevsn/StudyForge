extends Node

## Animation adapter for imported humanoid GLB rigs.
## It auto-discovers an AnimationPlayer under CharacterModel when no explicit path is set.

@export var animation_player_path: NodePath
@export var idle_animation := "Idle"
@export var walk_animation := "Walk"
@export var run_animation := "Running_A"
@export var jump_animation := "Jump"
@export var attack_animation := "2H_Melee_Attack_Chop"

var animation_player: AnimationPlayer

func _ready() -> void:
	if animation_player_path != NodePath():
		animation_player = get_node_or_null(animation_player_path) as AnimationPlayer
	if animation_player == null:
		var owner_model: Node = get_parent().get_node_or_null("CharacterModel")
		if owner_model == null:
			owner_model = get_parent().get_node_or_null("Visual")
		if owner_model:
			var players := owner_model.find_children("*", "AnimationPlayer", true, false)
			if not players.is_empty():
				animation_player = players[0] as AnimationPlayer

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
	_play_if_available(target, [idle_animation, walk_animation, run_animation, jump_animation, attack_animation])

func _play_if_available(target: String, aliases: Array[String]) -> void:
	if animation_player.has_animation(target):
		if animation_player.current_animation != target:
			animation_player.play(target)
		return
	for alias in aliases:
		if animation_player.has_animation(alias):
			if animation_player.current_animation != alias:
				animation_player.play(alias)
			return
