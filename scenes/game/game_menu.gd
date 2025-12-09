extends Node2D

@onready var settings_menu: Panel = $CanvasLayer/SettingsMenu
@onready var scores_rank: Label = $CanvasLayer/HighScoresMenu/Scores/Panel/VBoxContainer/Values/Rank
@onready var scores_score: Label = $CanvasLayer/HighScoresMenu/Scores/Panel/VBoxContainer/Values/Score
@onready var times_rank: Label = $CanvasLayer/HighScoresMenu/Times/Panel/VBoxContainer/Values/Rank
@onready var times_time: Label = $CanvasLayer/HighScoresMenu/Times/Panel/VBoxContainer/Values/Time
@onready var high_scores_menu: TabContainer = $CanvasLayer/HighScoresMenu

var scores: Array = []
var times: Array = []

func _ready() -> void:
	# load high scores
	scores.clear()
	times.clear()
	read_numbers_from_file("res://best_scores.txt", scores)
	display_numbers(scores, scores_rank, scores_score)
	read_numbers_from_file("res://best_times.txt", times)
	display_numbers(times, times_rank, times_time)
	
	# make sure menus are invisible
	settings_menu.visible = false
	high_scores_menu.visible = false
	
	# unpause game if game is paused
	if get_tree().paused == true:
		get_tree().paused = false

# button effects
func _on_any_button_pressed():
	$ClickSound.play()
	
func _on_any_button_hovered():
	$HoverSound.play()

# start button
func _on_start_button_pressed() -> void:
	TransitionScreen.transition()
	_on_any_button_pressed()
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://scenes/game/game.tscn")

func _on_start_button_mouse_entered() -> void:
	_on_any_button_hovered()

# exit button
func _on_exit_button_pressed() -> void:
	TransitionScreen.transition()
	_on_any_button_pressed()
	await get_tree().create_timer(0.5).timeout
	get_tree().quit()

func _on_exit_button_mouse_entered() -> void:
	_on_any_button_hovered()

# settings button
func _on_settings_button_pressed() -> void:
	_on_any_button_pressed()
	settings_menu.visible = true

func _on_settings_button_mouse_entered() -> void:
	_on_any_button_hovered()

# settings menu back button
func _on_back_button_pressed() -> void:
	_on_any_button_pressed()
	settings_menu.visible = false

func _on_back_button_mouse_entered() -> void:
	_on_any_button_hovered()

# high score menu tabs
func _on_high_scores_menu_tab_clicked(_tab: int) -> void:
	_on_any_button_pressed()

func _on_high_scores_menu_tab_hovered(tab: int) -> void:
	if high_scores_menu.current_tab != tab:
		_on_any_button_hovered()

# high score menu back button
func _on_back_pressed() -> void:
	_on_any_button_pressed()
	high_scores_menu.visible = false
	high_scores_menu.current_tab = 0

func _on_back_mouse_entered() -> void:
	_on_any_button_hovered()

# high score button
func _on_high_scores_button_pressed() -> void:
	_on_any_button_pressed()
	high_scores_menu.visible = true

func _on_high_scores_button_mouse_entered() -> void:
	_on_any_button_hovered()

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

# function to display numbers in labels
func display_numbers(arrNumbers: Array, labelRank: Label, labelValue: Label):
	var rank: int = 1
	
	var ranks: String = ""
	var values: String = ""
	
	for num in arrNumbers:
		ranks += str(rank) + "\n"
		values += str(num) + "\n"
		rank += 1
	
	labelRank.text = ranks
	labelValue.text = values
