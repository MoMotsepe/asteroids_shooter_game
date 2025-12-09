extends Area2D

signal AreaClicked

func _ready():
	connect("input_event", Callable(self, "_on_input_event"))

func _on_input_event(_viewport, event, _shape_idx):
	if (event.is_action_pressed("Press")):
		AreaClicked.emit()
