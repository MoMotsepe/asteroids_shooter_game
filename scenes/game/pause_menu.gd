# pause menu
extends Panel

@onready var settings: VBoxContainer = $Settings
@onready var main_menu: VBoxContainer = $MainMenu

func _ready() -> void:
	main_menu.visible = true
	settings.visible = false

func _on_any_button_pressed():
	$ClickSound.play()
	
func _on_any_button_hovered():
	$HoverSound.play()

# open settings
func _on_settings_button_pressed() -> void:
	_on_any_button_pressed()
	await get_tree().create_timer(0.2).timeout
	settings.visible = true
	main_menu.visible = false

# quit to menu
func _on_to_menu_pressed() -> void:
	var time_played: int = int($"../../UI_Manager/TimeLabel".text)
	var scores: Array = []
	var times: Array = []
	
	# save scores to files
	add_number_to_file(Score.getScore(), "res://best_scores.txt", scores)
	add_number_to_file(time_played, "res://best_times.txt", times)
	
	TransitionScreen.transition()
	_on_any_button_pressed()
	await get_tree().create_timer(0.562).timeout
	get_tree().change_scene_to_file("res://scenes/game/game_menu.tscn")

# open main pause menu
func _on_back_button_pressed() -> void:
	_on_any_button_pressed()
	await get_tree().create_timer(0.2).timeout
	settings.visible = false
	main_menu.visible = true

# display correct menu on next pause
func _on_hidden() -> void:
	main_menu.visible = true
	settings.visible = false

# resume game
func _on_resume_pressed() -> void:
	_on_any_button_pressed()
	await get_tree().create_timer(0.2).timeout
	get_tree().paused = false
	self.visible = false

# restart game
func _on_restart_pressed() -> void:
	TransitionScreen.transition()
	_on_any_button_pressed()
	await get_tree().create_timer(0.6).timeout
	get_tree().reload_current_scene()

# mouse hover sounds
func _on_resume_mouse_entered() -> void:
	_on_any_button_hovered()

func _on_restart_mouse_entered() -> void:
	_on_any_button_hovered()

func _on_settings_button_mouse_entered() -> void:
	_on_any_button_hovered()

func _on_to_menu_mouse_entered() -> void:
	_on_any_button_hovered()

func _on_back_button_mouse_entered() -> void:
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
