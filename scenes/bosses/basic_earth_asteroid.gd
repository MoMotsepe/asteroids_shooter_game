#earth boss asteroid
extends Area2D

#linked variables
@onready var healthbar: Healthbar = $Healthbar
@onready var asteroid_timer: Timer = $AsteroidTimer
@export var regular_asteroid = preload("res://scenes/asteroids/regular_asteroid.tscn")
@onready var sprite: Node3D = $"SubViewportContainer/SubViewport/Earth Asteroid"
@onready var particles: CPUParticles2D = $Effects/CPUParticles2D
@onready var effect_timer: Timer = $Effects/EffectTimer
@onready var explosion_sound: AudioStreamPlayer2D = $Effects/Explosion_Sound
@onready var collision_polygon: CollisionPolygon2D = $CollisionPolygon2D
@onready var collision_particles: CPUParticles2D = $Effects/CollisionParticles
@onready var collision_sound: AudioStreamPlayer2D = $Effects/CollisionSound

#asteroid properties
@export var damage: int = 10000 : set = set_damage, get = get_damage
@export var worth = 5
@export var health_multiplier: float = 1 : set = set_multiplier
var movement_speed: int = 100
var max_health: int = 500
var health: int = 500
var inside_effect_areas: Array = []
#signal for when astriod is destroyd
signal astriod_destroyed(worth: int)

#random values
var rng = RandomNumberGenerator.new()

func _ready() -> void:
	#set health
	healthbar.set_max_health(max_health)
	healthbar.set_health(health)
	asteroid_timer.start()

func _process(delta: float) -> void:
	#handle movement
	if position.y <=0:
		position.y += movement_speed*delta
	
	#apply effects from all areas
	var total_dps: int = 0
	for area in inside_effect_areas:
		total_dps += area.getDamage()
	
	if total_dps > 0:
		apply_damage(int(total_dps * delta))

# apply area damage
func apply_damage(value: int):
	var new_health = healthbar.get_health() - value
	healthbar.set_health(new_health)

#change properties
func set_damage(value: int):
	damage = 10000 if value <= 0 else value

func get_damage() -> int:
	return damage

func set_multiplier(value: float):
	health_multiplier = 1.0 if value <= 0.0 else value
	healthbar.set_max_health(int(max_health * health_multiplier))
	healthbar.set_health(int(health * health_multiplier))

func _on_area_entered(area: Area2D) -> void:
	#bullet collision
	if area.get_collision_layer_value(4):
		var new_health = healthbar.get_health() - area.get_damage()
		healthbar.set_health(new_health)
		if (healthbar.get_health() > 0):
			call_deferred("_on_collision")
	
	# effect area
	if area.get_collision_layer_value(8):
		inside_effect_areas.append(area)
	
	# fire & ice bullet collision
	if area.get_collision_layer_value(7):
		if (healthbar.get_health() > 0):
			call_deferred("_on_collision")

#boss defeated
func _on_healthbar_health_depleted() -> void:
	#remove asteroids
	self.remove_from_group("Asteroids")
	var asteroids = get_tree().get_nodes_in_group("Asteroids")
	for spawned_asteroid in asteroids:
		spawned_asteroid.queue_free()
	
	#remove boss
	emit_signal("astriod_destroyed", get_worth())
	Score.addScore(250)
	
	#effects
	if collision_polygon != null:
		collision_polygon.queue_free()
	sprite.visible = false
	healthbar.visible = false
	effect_timer.start()
	explosion_sound.play()
	particles.emitting = true

#to get the currency when astriod is destroyed
func get_worth() -> int:
	return worth

func _on_asteroid_timer_timeout() -> void:
	#create new asteroid
	var random_x = rng.randf_range(400, 1500)
	var new_asteroid = regular_asteroid.instantiate()
	new_asteroid.position = Vector2(random_x, 32)
	new_asteroid.add_to_group("Asteroids")
	get_tree().current_scene.add_child(new_asteroid)

# remove asteroid after effects have played
func _on_effect_timer_timeout() -> void:
	queue_free()

# stop area damage
func _on_area_exited(area: Area2D) -> void:
	if area.get_collision_layer_value(8):
		inside_effect_areas.erase(area)

# collision effect
func _on_collision():
	var x_offset = rng.randf_range(-350, 350)
	collision_particles.position.x = x_offset
	collision_particles.emitting = true
	collision_sound.play()
