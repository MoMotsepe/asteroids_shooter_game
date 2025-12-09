#brute asteroid
extends Area2D

@onready var healthbar: Healthbar = $Healthbar
@onready var sprite: Node3D = $"SubViewportContainer/SubViewport/Brute Asteroid"
@onready var particles: CPUParticles2D = $Effects/CPUParticles2D
@onready var effect_timer: Timer = $Effects/EffectTimer
@onready var explosion_sound: AudioStreamPlayer2D = $Effects/Explosion_Sound
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var collision_particles: CPUParticles2D = $Effects/CollisionParticles
@onready var collision_sound: AudioStreamPlayer2D = $Effects/CollisionSound
@onready var camera: Camera3D = $SubViewportContainer/SubViewport/Camera3D_Brute_asteriod

@export var regular_asteroid = preload("res://scenes/asteroids/brute_small.tscn")
@export var worth = 1
@export var health_multiplier: float = 1 : set = set_multiplier

#asteroid properties
@export var damage: int = 10 : set = set_damage, get = get_damage
@export var movement_speed: int = 50 : set = set_movement_speed, get = get_movement_speed
var max_health: int = 20
var health: int = 30
var current_speed: int
var inside_effect_areas: Array = []
#signal for when astriod is destroyd
signal astriod_destroyed(worth: int)

#random values
var rng = RandomNumberGenerator.new()
var x_movement = rng.randf_range(-0.5, 0.5)
#var rotation_value = rng.randf_range(-1, 1)

func _ready() -> void:
	#set health
	healthbar.set_max_health(max_health)
	healthbar.set_health(health)
	current_speed = movement_speed

func _process(delta: float) -> void:
	#handle movement
	position += Vector2(x_movement*current_speed*delta, current_speed*delta)
	#rotation_degrees += rotation_value
	
	#remove when off screen
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
	if healthbar.get_health() > 0:
		var new_health = healthbar.get_health() - value
		healthbar.set_health(new_health)

#change properties
func set_damage(value: int):
	damage = 1 if value <= 0 else value

func get_damage() -> int:
	return damage

func set_movement_speed(value: int):
	movement_speed = 1 if value <= 0 else value

func get_movement_speed() -> int:
	return movement_speed

func set_multiplier(value: float):
	health_multiplier = 1.0 if value <= 0.0 else value
	healthbar.set_max_health(int(max_health * health_multiplier))
	healthbar.set_health(int(health * health_multiplier))

#collision handler
func _on_area_entered(area: Area2D) -> void:
	#border collision
	if area.get_collision_layer_value(3):
		x_movement *= -1
	#bullet collision
	if area.get_collision_layer_value(4):
		var new_health = healthbar.get_health() - area.get_damage()
		healthbar.set_health(new_health)
		if (healthbar.get_health() > 0):
			call_deferred("_on_collision")
	#earth collision
	if area.get_collision_layer_value(1):
		#effects
		self.remove_from_group("Asteroids")
		if collision_shape != null:
			collision_shape.queue_free()
		sprite.visible = false
		if camera != null:
			camera.queue_free()
		effect_timer.start()
		explosion_sound.play()
		particles.emitting = true
	# effect area
	if area.get_collision_layer_value(8):
		inside_effect_areas.append(area)
	# fire & ice bullet collision
	if area.get_collision_layer_value(7):
		if (healthbar.get_health() > 0):
			call_deferred("_on_collision")

#asteroid destroyed
func _on_healthbar_health_depleted() -> void:
	if collision_shape != null:
		collision_shape.queue_free()
	#spawn two regular asteroids
	call_deferred("_deferred_spawn_asteroid", 50)
	call_deferred("_deferred_spawn_asteroid", -50)
	emit_signal("astriod_destroyed", get_worth())
	
	Score.addScore(100)
	
	#effects
	self.remove_from_group("Asteroids")
	if collision_shape != null:
		collision_shape.queue_free()
	sprite.visible = false
	if camera != null:
		camera.queue_free()
	effect_timer.start()
	explosion_sound.play()
	particles.emitting = true

func _deferred_spawn_asteroid(offset):
	var new_asteroid = regular_asteroid.instantiate()
	new_asteroid.position = Vector2(position.x+offset, position.y)
	new_asteroid.add_to_group("Asteroids")
	get_tree().current_scene.add_child(new_asteroid)

#to get the currency when astriod is destroyed
func get_worth() -> int:
	return worth

# remove asteroid after effects have played
func _on_effect_timer_timeout() -> void:
	queue_free()

# stop area damage
func _on_area_exited(area: Area2D) -> void:
	if area.get_collision_layer_value(8):
		inside_effect_areas.erase(area)

# collision effect
func _on_collision():
	collision_particles.emitting = true
	collision_sound.play()
