# FireAsteroid.gd
extends Area2D

@onready var healthbar: Healthbar = $Healthbar
@onready var sprite: Node3D = $"SubViewportContainer/SubViewport/Fire Asteroid"
@onready var particles: CPUParticles2D = $Effects/CPUParticles2D
@onready var effect_timer: Timer = $Effects/EffectTimer
@onready var explosion_sound: AudioStreamPlayer2D = $Effects/Explosion_Sound
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var collision_particles: CPUParticles2D = $Effects/CollisionParticles
@onready var collision_sound: AudioStreamPlayer2D = $Effects/CollisionSound
@onready var camera: Camera3D = $SubViewportContainer/SubViewport/Camera3D_Fire_asteriod

# Asteroid properties
@export var damage_per_second: int = 3  # Fire DOT damage per tick
@export var dot_duration: float = 5.0   # Total DOT duration
@export var dot_interval: float = 1.0   # How often damage ticks
@export var movement_speed: int = 150
@export var worth: int = 1
@export var health_multiplier: float = 1 : set = set_multiplier

var max_health: int = 20
var health: int = 20
var current_speed: int
var inside_effect_areas: Array = []
signal astriod_destroyed(worth: int)

# Random movement
var rng = RandomNumberGenerator.new()
var x_movement: float = rng.randf_range(-0.5, 0.5)

func _ready() -> void:
	# Set health
	healthbar.set_max_health(max_health)
	healthbar.set_health(health)
	current_speed = movement_speed

func _process(delta: float) -> void:
	# Move asteroid
	position += Vector2(x_movement * current_speed * delta, current_speed * delta)

	# Remove if off-screen
	if not get_viewport_rect().has_point(global_position):
		queue_free()
	
	#apply effects from all areas
	var total_dps: int = 0
	var speed_multiplier: float = 1.0
	for area in inside_effect_areas:
		total_dps += area.getDamage()
		speed_multiplier = area.getSpeedMultiplier()
	
	if total_dps > 0:
		apply_damage(int(total_dps * delta))
	current_speed = int(movement_speed * speed_multiplier)

# apply area damage
func apply_damage(value: int):
	var new_health = healthbar.get_health() - value
	healthbar.set_health(new_health)

# --- Getters / Setters ---
func set_damage(value: int) -> void:
	damage_per_second = max(1, value)

func get_damage() -> int:
	return damage_per_second

func set_movement_speed(value: int) -> void:
	movement_speed = max(1, value)

func get_movement_speed() -> int:
	return movement_speed

func set_multiplier(value: float):
	health_multiplier = 1.0 if value <= 0.0 else value
	healthbar.set_max_health(int(max_health * health_multiplier))
	healthbar.set_health(int(health * health_multiplier))

# --- Collision ---
func _on_area_entered(area: Area2D) -> void:
	# Bounce off borders
	if area.get_collision_layer_value(3):
		x_movement *= -1

	# Bullet collision
	if area.get_collision_layer_value(4):
		var new_health = healthbar.get_health() - area.get_damage()
		healthbar.set_health(new_health)
		if (healthbar.get_health() > 0):
			call_deferred("_on_collision")
	
	# Earth collision
	if area.get_collision_layer_value(1):
		var earth = _find_earth_node(area)
		if earth:
			# Apply DOT to Earth
			if earth.has_method("start_fire_dot"):
				earth.start_fire_dot(damage_per_second, dot_duration, dot_interval)
				print("Fire DOT started on Earth from asteroid")

			# Show fire effects on all turrets
			_apply_turret_fire_effects()

			# Trigger asteroid explosion & hide
			_destroy_asteroid()
	
	# effect area
	if area.get_collision_layer_value(8):
		inside_effect_areas.append(area)
	# fire & ice bullet collision
	if area.get_collision_layer_value(7):
		if (healthbar.get_health() > 0):
			call_deferred("_on_collision")

# Stop fire if asteroid leaves (optional)
# stop area damage
func _on_area_exited(area: Area2D) -> void:
	if area.get_collision_layer_value(8):
		inside_effect_areas.erase(area)

# --- Helpers ---
func _apply_turret_fire_effects() -> void:
	var turrets = get_tree().get_nodes_in_group("turrets")
	for turret in turrets:
		if turret.has_method("show_fire_effect"):
			turret.show_fire_effect(dot_interval)

func _find_earth_node(collider: Node) -> Node:
	var node = collider
	while node:
		if node.has_method("start_fire_dot"):
			return node
		node = node.get_parent()
	return null

# --- Asteroid destruction ---
func _destroy_asteroid() -> void:
	self.remove_from_group("Asteroids")
	sprite.visible = false
	if camera != null:
		camera.queue_free()
	if collision_shape != null:
		collision_shape.queue_free()
	effect_timer.start()
	explosion_sound.play()
	particles.emitting = true

func _on_healthbar_health_depleted() -> void:
	emit_signal("astriod_destroyed", get_worth())
	Score.addScore(75)
	_destroy_asteroid()

#to get the currency when astriod is destroyed
func get_worth() -> int:
	return worth

func _on_effect_timer_timeout() -> void:
	queue_free()

# collision effect
func _on_collision():
	collision_particles.emitting = true
	collision_sound.play()
