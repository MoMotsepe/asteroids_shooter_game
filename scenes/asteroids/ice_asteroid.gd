# IceAsteroid.gd
extends Area2D

@onready var healthbar: Healthbar = $Healthbar
@onready var sprite: Node3D = $SubViewportContainer/SubViewport/Ice_Asteroid
@onready var particles: CPUParticles2D = $Effects/CPUParticles2D
@onready var effect_timer: Timer = $Effects/EffectTimer
@onready var explosion_sound: AudioStreamPlayer2D = $Effects/Explosion_Sound
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var collision_particles: CPUParticles2D = $Effects/CollisionParticles
@onready var collision_sound: AudioStreamPlayer2D = $Effects/CollisionSound
@onready var camera: Camera3D = $SubViewportContainer/SubViewport/Camera3D_ice_Asteriod

@export var worth = 1

# Asteroid properties
@export var damage: int = 5                 # initial damage
@export var dot_damage: int = 1             # damage over time per tick
@export var dot_duration: float = 5.0       # seconds
@export var turret_stun_duration: float = 2 #1.5 is normal
@export var movement_speed: int = 150
@export var health_multiplier: float = 1 : set = set_multiplier
var max_health: int = 20
var health: int = 20
var current_speed: int
var inside_effect_areas: Array = []
#signal for when astriod is destroyd
signal astriod_destroyed(worth: int)

# Random movement
var rng = RandomNumberGenerator.new()
var x_movement = rng.randf_range(-0.5, 0.5)
#var rotation_value = rng.randf_range(-1.0, 1.0)

# DOT handling
var dot_timer: Timer
var target_dot: Node = null
var dot_elapsed: float = 0.0

func _ready() -> void:
	# Set health
	healthbar.set_max_health(max_health)
	healthbar.set_health(health)
	current_speed = movement_speed
	
	# Timer for DOT ticks
	dot_timer = Timer.new()
	dot_timer.wait_time = 1.0
	dot_timer.one_shot = false
	dot_timer.autostart = false
	add_child(dot_timer)
	dot_timer.timeout.connect(Callable(self, "_on_dot_tick"))
	

func _process(delta: float) -> void:
	# Movement
	position += Vector2(x_movement * current_speed * delta, current_speed * delta)
	#rotation_degrees += rotation_value
	
	# Remove if off screen
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
	
	# Handle DOT duration
	if target_dot:
		dot_elapsed += delta
		if dot_elapsed >= dot_duration:
			target_dot = null
			dot_timer.stop()
			dot_elapsed = 0

# apply area damage
func apply_damage(value: int):
	var new_health = healthbar.get_health() - value
	healthbar.set_health(new_health)

# --- Getter and Setter functions ---
func set_damage(value: int) -> void:
	damage = max(1, value)

func get_damage() -> int:
	return damage

func set_dot_damage(value: int) -> void:
	dot_damage = max(1, value)

func get_dot_damage() -> int:
	return dot_damage

func set_movement_speed(value: int) -> void:
	movement_speed = max(1, value)

func get_movement_speed() -> int:
	return movement_speed

func set_multiplier(value: float):
	health_multiplier = 1.0 if value <= 0.0 else value
	healthbar.set_max_health(int(max_health * health_multiplier))
	healthbar.set_health(int(health * health_multiplier))

# Collision handling
func _on_area_entered(area: Area2D) -> void:
	# Border collision
	if area.get_collision_layer_value(3):
		x_movement *= -1
	
	# Bullet collision
	if area.get_collision_layer_value(4):
		healthbar.set_health(healthbar.get_health() - area.get_damage())
		if (healthbar.get_health() > 0):
			call_deferred("_on_collision")
	
	# Earth collision
	if area.get_collision_layer_value(1):
		if area.has_method("apply_damage"):
			area.apply_damage(damage)
		
		# Apply stun + DOT to all turrets
		var turrets = get_tree().get_nodes_in_group("turrets")
		for turret in turrets:
			if turret.has_method("stun"):
				turret.stun(turret_stun_duration)
				
			if turret.has_method("apply_damage"):
				target_dot = turret
				dot_elapsed = 0
				dot_timer.start()
			#ice effects on turrets
			
		
		#effects
		self.remove_from_group("Asteroids")
		sprite.visible = false
		if camera != null:
			camera.queue_free()
		if collision_shape != null:
			collision_shape.queue_free()
		effect_timer.start()
		explosion_sound.play()
		particles.emitting = true
	
	# Turret collision
	if area.get_collision_layer_value(6):  # turret layer
		var turret = area.get_parent()        # climb to turret node
		if turret:
			# Apply initial damage
			if turret.has_method("apply_damage"):
				turret.apply_damage(damage)
			# Apply stun
			if turret.has_method("stun"):
				turret.stun(turret_stun_duration)
			# Start DOT
			if turret.has_method("apply_damage"):
				target_dot = turret
				dot_elapsed = 0
				dot_timer.start()
	
	# effect area
	if area.get_collision_layer_value(8):
		inside_effect_areas.append(area)
	# fire & ice bullet collision
	if area.get_collision_layer_value(7):
		if (healthbar.get_health() > 0):
			call_deferred("_on_collision")

# DOT tick
func _on_dot_tick() -> void:
	if target_dot and target_dot.has_method("apply_damage"):
		target_dot.apply_damage(dot_damage)

# Asteroid destroyed
func _on_healthbar_health_depleted() -> void:
	emit_signal("astriod_destroyed", get_worth())
	Score.addScore(75)
	
	#effects
	self.remove_from_group("Asteroids")
	sprite.visible = false
	if camera != null:
		camera.queue_free()
	if collision_shape != null:
		collision_shape.queue_free()
	effect_timer.start()
	explosion_sound.play()
	particles.emitting = true

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
