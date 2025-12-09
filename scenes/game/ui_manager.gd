#ui elements
extends Control

@onready var score_label: Label = $ScoreLabel
@onready var time_label: Label = $TimeLabel
@onready var game_timer: Timer = $GameTimer
@onready var black_hole_timer: Timer = $BlackHole/BlackHoleTimer
@onready var black_hole_button: TextureButton = $BlackHole/BlackHoleButton
@onready var shield_timer: Timer = $Shield/ShieldTimer
@onready var shield_button: TextureButton = $Shield/ShieldButton
@onready var shock_wave_timer: Timer = $ShockWave/ShockWaveTimer
@onready var shock_wave_button: TextureButton = $ShockWave/ShockWaveButton
@onready var button_activate: AudioStreamPlayer2D = $ButtonActivate
@onready var speed_removal_zone: CollisionShape2D = $ShockWave/SpeedRemovalZone/CollisionShape2D

var time_played: int = 0

func _ready() -> void:
	game_timer.start()
	Score.setScore(0)
	
	# special abilities
	black_hole_timer.start()
	black_hole_button.disabled = true
	shield_timer.start()
	shield_button.disabled = true
	shock_wave_timer.start()
	shock_wave_button.disabled = true
	speed_removal_zone.disabled = true

func _process(_delta: float) -> void:
	score_label.text = str(Score.getScore())
	call_deferred("checkAbilities")

func _on_game_timer_timeout() -> void:
	time_played += 1
	time_label.text = str(time_played)

# enable black hole ability
func _on_black_hole_timer_timeout() -> void:
	black_hole_timer.stop()

# enable shield ability
func _on_shield_timer_timeout() -> void:
	shield_timer.stop()

# enable shock wave ability
func _on_shock_wave_timer_timeout() -> void:
	shock_wave_timer.stop()

func checkAbilities():
	#shield
	if shield_timer.is_stopped():
		if Currency.getCurrency() >= 25:
			if shield_button.disabled == true:
				shield_button.disabled = false
				button_activate.play()
		else:
			shield_button.disabled = true
	
	#shock wave
	if shock_wave_timer.is_stopped():
		if Currency.getCurrency() >= 20:
			if shock_wave_button.disabled == true:
				shock_wave_button.disabled = false
				button_activate.play()
		else:
			shock_wave_button.disabled = true
	
	#black hole
	if black_hole_timer.is_stopped():
		if Currency.getCurrency() >= 40:
			if black_hole_button.disabled == true:
				black_hole_button.disabled = false
				button_activate.play()
		else:
			black_hole_button.disabled = true

# restart cooldowns after use
func _on_black_hole_button_black_hole_finished() -> void:
	black_hole_timer.start()

func _on_shock_wave_button_shock_wave_finished() -> void:
	shock_wave_timer.start()

func _on_shield_button_shield_finished() -> void:
	shield_timer.start()
