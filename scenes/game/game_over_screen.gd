# game over screen
extends Panel

@onready var score_label: Label = $VBoxContainer/Score/Value
@onready var time_label: Label = $VBoxContainer/Time/Value
@onready var click_sound: AudioStreamPlayer2D = $ClickSound
@onready var hover_sound: AudioStreamPlayer2D = $HoverSound

func _on_restart_pressed() -> void:
	TransitionScreen.transition()
	click_sound.play()
	await get_tree().create_timer(0.6).timeout
	get_tree().reload_current_scene()

func _on_to_menu_pressed() -> void:
	TransitionScreen.transition()
	click_sound.play()
	await get_tree().create_timer(0.562).timeout
	get_tree().change_scene_to_file("res://scenes/game/game_menu.tscn")

func setScore():
	score_label.text = str(Score.getScore())

func setTime(time: int):
	time_label.text = str(time)

func _on_restart_mouse_entered() -> void:
	hover_sound.play()

func _on_to_menu_mouse_entered() -> void:
	hover_sound.play()
