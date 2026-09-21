extends Node

@export var max_health := 100
var health := 100

signal health_changed(current: int, maximum: int)
signal died

func _ready() -> void:
	health = max_health

func take_damage(amount: int) -> void:
	if health <= 0:
		return
	health = max(health - amount, 0)
	health_changed.emit(health, max_health)
	if health == 0:
		died.emit()

func heal(amount: int) -> void:
	health = min(health + amount, max_health)
	health_changed.emit(health, max_health)
