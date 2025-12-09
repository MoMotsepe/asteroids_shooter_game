# GameManager.gd  (full drop-in)
extends Node2D
class_name GameManager

# --- Nodes ---
@onready var asteroid_timer: Timer = $Timers/AsteroidTimer
@onready var round_timer:   Timer = $Timers/RoundTimer
@onready var buildup_timer: Timer = $Timers/BuildupTimer
@onready var boss_label:    Label = $BossLabel
@onready var game_over_screen: Panel = $CanvasLayer/GameOverScreen

# --- Scenes ---
var regular_asteroid : Object  = preload("res://scenes/asteroids/regular_asteroid.tscn")
var brute_asteroid  : Object  = preload("res://scenes/asteroids/brute_asteroid.tscn")
var fire_asteroid   : Object  = preload("res://scenes/asteroids/fire_asteroid.tscn")
var parasite_asteroid : Object = preload("res://scenes/asteroids/parasite_asteroid.tscn")
var ice_asteroid : Object = preload("res://scenes/asteroids/ice_asteroid.tscn")
var normal_turret : Object = preload("res://scenes/turrets/normal_turret.tscn")
var earth_asteroid : Object = preload("res://scenes/bosses/basic_earth_asteroid.tscn")

# --- HUD ---
var hud: HUD

# --- Drop system (Titaterarium) ---
@export var titaterarium_rolls_per_kill: int = 1
@export var default_titaterarium_chance: float = 0.20
@export var default_titaterarium_min: int = 1
@export var default_titaterarium_max: int = 2

var TITATERARIUM_PROFILE := {
	&"regular":  {"chance": 0.25, "min": 1, "max": 2}, #chance = 0.15
	&"brute":    {"chance": 0.4, "min": 1, "max": 3}, #0.3
	&"fire":     {"chance": 0.3, "min": 1, "max": 2},#0.25
	&"ice":      {"chance": 0.3, "min": 1, "max": 2},#0.20
	&"parasite": {"chance": 0.4, "min": 2, "max": 3},#0.40
}

# --- Boss movement ---
var boss_fall_speed: float = 20.0
var boss_active: bool = false

# --- Difficulty / spawn ranges ---
var asteroid_wait_time: float = 4.0
var asteroid_range_lower: float = 450.0
var asteroid_range_upper: float = 1450.0
var health_multiplier: float = 1.0

# --- RNG (single source of truth) ---
var rng : Object = RandomNumberGenerator.new()

func _ready() -> void:
	if (get_tree().paused):
		get_tree().paused = false
	
	if get_tree().current_scene != self:
		get_tree().current_scene = self

	rng.randomize()  # seed once

	add_turret()

	asteroid_timer.start()
	round_timer.start()

	hud = get_tree().get_first_node_in_group("hud")
	Currency.setCurrency(10)
	if hud:
		hud.update_currency()
		hud.cur_label_test()

func add_turret() -> void:
	var new_turret : Object = normal_turret.instantiate()
	new_turret.position = Vector2(950, 699)
	get_tree().current_scene.add_child(new_turret)

func _on_asteroid_timer_timeout() -> void:
	# Hard stop during boss phase
	if boss_active:
		return

	var new_asteroid : Object
	var random_type : int = rng.randi_range(1, 101)
	var random_x : float   = rng.randf_range(asteroid_range_lower, asteroid_range_upper)

	if random_type > 80:
		new_asteroid = regular_asteroid.instantiate()
	elif random_type > 60:
		new_asteroid = brute_asteroid.instantiate()
	elif random_type > 40:
		new_asteroid = fire_asteroid.instantiate()
	elif random_type > 20:
		new_asteroid = ice_asteroid.instantiate()
	else:
		new_asteroid = parasite_asteroid.instantiate()

	new_asteroid.position = Vector2(random_x, 32)
	new_asteroid.add_to_group("Asteroids")
	new_asteroid.connect("astriod_destroyed", Callable(self, "_on_astriod_destroyed"))
	get_tree().current_scene.add_child(new_asteroid)
	new_asteroid.set_multiplier(health_multiplier)

func _on_astriod_destroyed(worth: int, drop_key: StringName = &"") -> void:
	# 1) Award Plutonium
	Currency.add_currency(Currency.PLUTONIUM, worth)

	# 2) Roll for Titaterarium
	var profile = TITATERARIUM_PROFILE.get(drop_key, null)
	var chance : float = default_titaterarium_chance
	var a_min  : int = default_titaterarium_min
	var a_max  : int = default_titaterarium_max
	if profile != null:
		chance = float(profile["chance"])
		a_min  = int(profile["min"])
		a_max  = int(profile["max"])

	var gained : int = 0
	for i in range(titaterarium_rolls_per_kill):
		if rng.randf() < chance:
			gained += rng.randi_range(a_min, a_max)

	if gained > 0:
		Currency.add_currency(Currency.TITATERARIUM, gained)

	# 3) Refresh HUD safely
	if hud:
		hud.update_currency()
		hud.cur_label_test()
		if hud.has_method("update_titaterarium"):
			hud.update_titaterarium()

func _on_earth_end_game() -> void:
	get_tree().paused = true
	
	var scores: Array = []
	var times: Array = []
	var time_played: int = int($HUD/UI_Manager/TimeLabel.text)
	
	# save scores to files
	add_number_to_file(Score.getScore(), "res://best_scores.txt", scores)
	add_number_to_file(time_played, "res://best_times.txt", times)
	
	# set values on game over screen
	game_over_screen.setScore()
	game_over_screen.setTime(time_played)
	
	# display game over screen
	game_over_screen.visible = true
	$HUD/PauseButton.disabled = true

# Boss movement
func _physics_process(delta: float) -> void:
	for b in get_tree().get_nodes_in_group("Boss"):
		if is_instance_valid(b):
			b.position.y += boss_fall_speed * delta

# Boss phase start
func _on_round_timer_timeout() -> void:
	boss_active = true
	round_timer.stop()
	asteroid_timer.stop()
	buildup_timer.start()
	boss_label.visible = true

	# Clear field
	for asteroid in get_tree().get_nodes_in_group("Asteroids"):
		asteroid.queue_free()

# Boss spawn after buildup
func _on_buildup_timer_timeout() -> void:
	buildup_timer.stop()
	boss_label.visible = false

	var new_boss : Object = earth_asteroid.instantiate()
	new_boss.position = Vector2(950, -50)
	new_boss.add_to_group("Asteroids")
	new_boss.add_to_group("Boss")
	get_tree().current_scene.add_child(new_boss)
	new_boss.set_multiplier(health_multiplier)

	new_boss.connect("tree_exited", Callable(self, "_on_boss_removed"))

# Boss removed → resume waves + scale difficulty
func _on_boss_removed() -> void:
	boss_active = false

	if asteroid_range_lower > 25.0:
		asteroid_range_lower -= 100.0
	else:
		asteroid_range_lower = 25.0

	if asteroid_range_upper < 1875.0:
		asteroid_range_upper += 100.0
	else:
		asteroid_range_upper = 1875.0

	if asteroid_wait_time > 0.5:
		asteroid_wait_time -= 1.0
	else:
		asteroid_wait_time = 0.5

	health_multiplier *= 2.25
	asteroid_timer.wait_time = asteroid_wait_time

	asteroid_timer.start()
	round_timer.start()

func _getCurrency() -> int:
	return Currency.getCurrency()

# function to read numbers from file
func read_numbers_from_file(file_path: String, arrNumbers: Array):
	var file := FileAccess.open(file_path, FileAccess.READ)
	if file:
		while not file.eof_reached():
			var line = file.get_line().strip_edges()
			if line.is_valid_int():
				arrNumbers.append(int(line))
		file.close()
	else:
		push_error("Failed to open file: " + file_path)

# function to add numbers to file
func add_number_to_file(new_number: int, file_path: String, arrNumbers: Array):
	read_numbers_from_file(file_path, arrNumbers)
	arrNumbers.append(new_number)
	arrNumbers.sort()
	arrNumbers.reverse()
	if arrNumbers.size() > 10:
		arrNumbers.remove_at(10)
	
	# Write sorted numbers back to the file
	var file := FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		for n in arrNumbers:
			file.store_line(str(n))
		file.close()
	else:
		push_error("Failed to open file for writing: " + file_path)
