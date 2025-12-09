# Earth.gd
extends Area2D

signal EndGame

@onready var healthbar: Healthbar = $Healthbar
var max_health: int = 100
var health: int = max_health

# DOT Timer
var fire_dot_timer: Timer = null
var fire_dot_ticks_remaining: int = 0
var fire_dot_damage_per_tick: int = 0

func _ready() -> void:
	healthbar.set_max_health(max_health)
	healthbar.set_health(health)

func _on_area_entered(area: Area2D) -> void:
	if area.has_method("get_damage"):
		var new_health = healthbar.get_health() - area.get_damage()
		healthbar.set_health(new_health)

# Called by FireAsteroid
func start_fire_dot(damage: int, total_duration: float, tick_interval: float) -> void:
	# Calculate number of ticks
	fire_dot_ticks_remaining = int(total_duration / tick_interval)
	fire_dot_damage_per_tick = damage

	# Create Timer if it doesn't exist
	if not fire_dot_timer:
		fire_dot_timer = Timer.new()
		fire_dot_timer.one_shot = false
		add_child(fire_dot_timer)
		fire_dot_timer.connect("timeout", Callable(self, "_on_fire_dot_tick"))
	
	fire_dot_timer.wait_time = tick_interval
	fire_dot_timer.start()
	print("Fire DOT started: ", fire_dot_ticks_remaining, " ticks, ", fire_dot_damage_per_tick, " damage per tick")

func _on_fire_dot_tick() -> void:
	if fire_dot_ticks_remaining <= 0:
		fire_dot_timer.stop()
		print("Fire DOT ended")
		return

	# Apply damage
	var new_health = healthbar.get_health() - fire_dot_damage_per_tick
	healthbar.set_health(new_health)
	print("Fire DOT tick: ", fire_dot_damage_per_tick, " damage. Health: ", healthbar.get_health())

	# Trigger turret fire effects
	var turrets : Array = get_tree().get_nodes_in_group("turrets")
	for turret in turrets:
		if turret.has_method("show_fire_effect"):
			turret.show_fire_effect(fire_dot_timer.wait_time)

	fire_dot_ticks_remaining -= 1

	if health <= 0:
		_on_health_depleted()
		fire_dot_timer.stop()

func _on_health_depleted() -> void:
	EndGame.emit()

func _on_healthbar_health_depleted() -> void:
	EndGame.emit()
