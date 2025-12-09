extends CanvasLayer

signal on_transition_finished
@export var textrec : TextureRect
@export var animationPlayer : AnimationPlayer

func _ready() -> void:
	textrec.visible = false
	animationPlayer.animation_finished.connect(_on_animation_finished)
	
func _on_animation_finished(anim_name):
	if anim_name == "fade_to_black":
		on_transition_finished.emit()
		animationPlayer.play("fade_in")
	elif anim_name == "fade_in":
		textrec.visible = false

func transition():
	textrec.visible = true
	animationPlayer.play("fade_to_black")
