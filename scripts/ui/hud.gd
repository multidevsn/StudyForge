extends CanvasLayer

@onready var player: CharacterBody3D = get_parent().get_node("Player") as CharacterBody3D
@onready var status: Label = $Margin/VBox/Status
@onready var message: Label = $Margin/VBox/Message
@onready var region_label: Label = $Region

func _ready() -> void:
	add_to_group("hud")

func _process(_delta: float) -> void:
	var rpg = get_tree().get_first_node_in_group("rpg_system")
	var streamer = get_tree().get_first_node_in_group("region_streamer")
	if player and rpg:
		var speed := Vector2(player.velocity.x, player.velocity.z).length()
		status.text = "ECLYRIA // VALLEY OF ECHOES\nHP %d/%d  STA %d/100  LV %d  XP %d/%d  OR %d\nATK %d  SPD %.1f" % [
			player.health, player.max_health, int(player.stamina), rpg.level, rpg.xp, rpg.xp_to_next_level(), rpg.gold, player.attack_damage, speed
		]
	if streamer:
		var c: Vector2i = streamer.current_coord
		region_label.text = "REGION %d,%d  •  %d ACTIVE" % [c.x, c.y, streamer.loaded_regions.size()]

func show_message(text_value: String) -> void:
	message.text = text_value
	get_tree().create_timer(3.0).timeout.connect(func():
		if is_instance_valid(message):
			message.text = ""
	)
