extends CanvasLayer

@onready var player: CharacterBody3D = get_parent().get_node("Player")
@onready var status: Label = $Margin/VBox/Status
@onready var message: Label = $Margin/VBox/Message

func _ready() -> void:
	add_to_group("hud")

func _process(_delta: float) -> void:
	if player:
		var speed := Vector2(player.velocity.x, player.velocity.z).length()
		status.text = "ECLYRIA  //  VALLEY OF ECHOES\nHP  %d / 100     STAMINA  %d / 100\nSPD  %.1f     LEVEL  1\nWASD Move | SHIFT Sprint | SPACE Jump | LMB Attack | E Talk | F5 Save | F9 Load" % [player.health, int(player.stamina), speed]

func show_message(text_value: String) -> void:
	message.text = text_value
	get_tree().create_timer(2.5).timeout.connect(func():
		if is_instance_valid(message):
			message.text = ""
	)
