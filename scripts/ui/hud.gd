extends CanvasLayer
@onready var player: CharacterBody3D = get_parent().get_node("Player")
@onready var status: Label = $Margin/VBox/Status
@onready var message: Label = $Margin/VBox/Message

func _ready() -> void:
	add_to_group("hud")

func _process(_delta: float) -> void:
	var rpg := get_tree().get_first_node_in_group("rpg_system")
	if player and rpg:
		var speed := Vector2(player.velocity.x,player.velocity.z).length()
		status.text = "ECLYRIA // VALLEY OF ECHOES\nHP %d/%d  STA %d/100  LV %d  XP %d/%d  OR %d\nATK %d | I Inventaire | K Compétences | J Quêtes | U Équiper\nWASD Move | SHIFT Sprint | SPACE Jump | LMB Attack | E Interagir | F5/F9 Save/Load" % [player.health,player.max_health,int(player.stamina),rpg.level,rpg.xp,rpg.xp_to_next_level(),rpg.gold,player.attack_damage]

func show_message(text_value: String) -> void:
	message.text = text_value
	get_tree().create_timer(3.0).timeout.connect(func():
		if is_instance_valid(message): message.text = ""
	)
