#game quit button
extends TextureButton

@onready var PauseMenu: Panel = $PauseMenu

func ready():
	PauseMenu.visible = false
	loadPauseTextures()

func _process(_delta: float) -> void:
	if get_tree().paused:
		call_deferred("loadResumeTextures")
	else:
		call_deferred("loadPauseTextures")

func _on_pressed() -> void:
	if get_tree().paused:
		get_tree().paused = false
		PauseMenu.visible = false
	else:
		get_tree().paused = true
		PauseMenu.visible = true

func loadPauseTextures():
	texture_normal = load("res://assets/pngs/PauseButton/PauseButton.png")
	texture_hover = load("res://assets/pngs/PauseButton/PauseButtonHover.png")
	texture_click_mask = load("res://assets/pngs/PauseButton/PauseButtonClicked.png")

func loadResumeTextures():
	texture_normal = load("res://assets/pngs/PauseButton/ResumeButton.png")
	texture_hover = load("res://assets/pngs/PauseButton/ResumeButtonHover.png")
	texture_click_mask = load("res://assets/pngs/PauseButton/ResumeButtonClicked.png")
