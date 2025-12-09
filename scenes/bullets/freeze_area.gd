# freeze area
extends Area2D

@export var dps: int = 3 : set = setDamage, get = getDamage
@export var slow_factor: float = 0.2
@onready var particles: CPUParticles2D = $CPUParticles2D
@onready var timer: Timer = $Timer

func setDamage(value: int):
	dps = 1 if value <= 0 else value

func getDamage() -> int:
	return dps

func setSpeedMultiplier(value: float):
	slow_factor = 0.2 if (value <= 0 or value > 1) else value

func getSpeedMultiplier() -> float:
	return slow_factor

func _ready() -> void:
	particles.emitting = true
	timer.start()

# remove area
func _on_timer_timeout() -> void:
	queue_free()
