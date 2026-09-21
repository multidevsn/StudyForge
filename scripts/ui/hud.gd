extends CanvasLayer

@onready var player: CharacterBody3D = get_parent().get_node("Player")
@onready var status: Label = $Margin/VBox/Status

func _process(_delta: float) -> void:
	if player:
		var speed := Vector2(player.velocity.x, player.velocity.z).length()
		status.text = "ECLYRIA  //  VALLEY OF ECHOES\nHP  100 / 100     STAMINA  100 / 100\nSPD  %.1f     LEVEL  1" % speed
