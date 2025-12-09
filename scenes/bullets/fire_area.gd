# fire area
extends Area2D

@export var dps: int = 5 : set = setDamage, get = getDamage
@onready var particles: CPUParticles2D = $CPUParticles2D
@onready var timer: Timer = $Timer

func setDamage(value: int):
	dps = 1 if value <= 0 else value

func getDamage() -> int:
	return dps

func getSpeedMultiplier() -> float:
	return 1.0

func _ready() -> void:
	particles.emitting = true
	timer.start()

# remove area
func _on_timer_timeout() -> void:
	queue_free()
