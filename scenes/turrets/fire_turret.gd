extends Node2D  # Fire turret

@export var bullet_scene = preload("res://scenes/bullets/fire_bullet.tscn")
@export var upgrade_menu = preload("res://scenes/turrets/upgrade_menu.tscn")
@onready var timer: Timer = $Timer
@onready var muzzle: Marker2D = $Muzzle
@onready var shoot_sound: AudioStreamPlayer2D = $Shoot_Sound
@onready var menu_timer: Timer = $MenuTimer

@export var fire_rate: float = 1.5
@export var fire_range: float = 700.0
@export var bullet_damage: int = 5
@export var level: int = 1
var current_fire_rate: float
var is_stunned: bool = false
var is_on_fire: bool = false
var target: Node2D = null
var new_menu = null

func _ready() -> void:
	look_at(Vector2(position.x, 0))
	current_fire_rate = fire_rate
	_update_timer()
	#timer.timeout.connect(Callable(self, "_on_timer_timeout"))
	timer.start()

func _process(_delta: float) -> void:
	find_target()
	if target:
		look_at(target.global_position)

func find_target() -> void:
	var asteroids = get_tree().get_nodes_in_group("Asteroids")
	var nearest_dist : float = fire_range
	var nearest = null

	for asteroid in asteroids:
		var dist = global_position.distance_to(asteroid.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = asteroid

	target = nearest

func shoot() -> void:
	#create bullet
	if target:
		var bullet : Object = bullet_scene.instantiate()
		bullet.set_damage(bullet_damage)
		bullet.global_position = muzzle.global_position
		bullet.direction = (target.global_position - muzzle.global_position).normalized()
		bullet.look_at(target.global_position)
		get_tree().current_scene.add_child(bullet)
		shoot_sound.play()

func apply_fire_rate_debuff(percent: float) -> void:
	current_fire_rate *= (1.0 + (percent / 100.0))
	$SubViewportContainer/SubViewport/DirectionalLight3D.light_color = Color(0, 0.5, 0)
	_update_timer()
	print("Turret debuffed! New interval: ", current_fire_rate)

func show_fire_effect(duration: float) ->void:
	if is_on_fire:
		return
	
	is_on_fire = true
	timer.stop()
	
	$SubViewportContainer/SubViewport/DirectionalLight3D.light_color = Color(1, 0.5, 0)
	var firetimer : Timer = Timer.new()
	firetimer.wait_time = duration
	firetimer.one_shot = true
	add_child(firetimer)
	firetimer.start()
	firetimer.timeout.connect(Callable(self, "_reset_fire_effect"))
	
func _reset_fire_effect() ->void:
	is_on_fire = false
	timer.start()
	$SubViewportContainer/SubViewport/DirectionalLight3D.light_color = Color(255, 255, 255)

func _update_timer() -> void:
	timer.stop()
	timer.wait_time = current_fire_rate
	if not is_stunned:
		timer.start()

func stun(duration: float) -> void:
	if is_stunned:
		return
	is_stunned = true
	timer.stop()
	$SubViewportContainer/SubViewport/DirectionalLight3D.light_color = Color(0.5, 0.8, 1.0)
	var stun_timer : Timer = Timer.new()
	stun_timer.wait_time = duration
	stun_timer.one_shot = true
	add_child(stun_timer)
	stun_timer.start()
	stun_timer.timeout.connect(Callable(self, "_on_stun_timeout"))

func _on_stun_timeout() -> void:
	is_stunned = false
	timer.start()
	$SubViewportContainer/SubViewport/DirectionalLight3D.light_color = Color(255, 255, 255)
	print("Turret recovered from stun")

func _on_timer_timeout() -> void:
	if target:
		shoot()

# detect on click
func _on_area_2d_area_clicked() -> void:
	if (new_menu == null):
		# add menu
		new_menu = upgrade_menu.instantiate()
		get_tree().current_scene.add_child(new_menu)
		new_menu.position = self.position + Vector2(15, -150)
		
		#set menu variables
		new_menu.setLevel(level)
		new_menu.setType(3)
		
		#connect actions
		new_menu.Upgraded.connect(Callable(self,"_on_upgrade_button_pressed"))
		new_menu.DeleteTurret.connect(Callable(self,"_on_remove_button_pressed"))
		
		menu_timer.start()
	else:
		new_menu.queue_free()

# remove menu after 5 seconds
func _on_menu_timer_timeout() -> void:
	if (new_menu != null):
		new_menu.queue_free()

func _on_upgrade_button_pressed():
	if (new_menu != null):
		level += 1
		bullet_damage += 2
		print("Turret upgraded to level " + str(level) + "\nNew damage: " + str(bullet_damage))
		$Label.text = "Level: " + str(level)

func _on_remove_button_pressed():
	var placement_scene = load("res://scenes/map/placement_square.tscn")
	var placement_instance = placement_scene.instantiate()
	
	placement_instance.position.x = self.position.x - 65
	placement_instance.position.y = self.position.y - 66
	
	get_tree().current_scene.add_child(placement_instance)
	get_tree().current_scene.remove_child(self)
	new_menu.queue_free()
