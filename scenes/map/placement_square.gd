#turret placement square
extends TextureButton

#turret variables
var normal_turret = preload("res://scenes/turrets/normal_turret.tscn")
var piercing_turret = preload("res://scenes/turrets/piercing_turret.tscn")
var ice_turret = preload("res://scenes/turrets/ice_turret.tscn")
var fire_turret = preload("res://scenes/turrets/fire_turret.tscn")

@onready var turret_menu: TextureRect = $TurretMenu
@onready var menu_timer: Timer = $MenuTimer

func _on_toggled(toggled_on: bool) -> void:
	#show and hide menu
	if (toggled_on == true):
		turret_menu.visible = true
		menu_timer.start()
	else:
		turret_menu.visible = false
		menu_timer.stop()

func _on_turret_menu_turret_selected() -> void:
	#add normal turret
	var new_turret : Object = normal_turret.instantiate()
	new_turret.position = Vector2((position.x*2+size.x)/2, (position.y*2+size.y)/2)
	get_tree().current_scene.add_child(new_turret)
	turret_menu.visible = false
	
	self.queue_free()
	
func _on_piercing_turret_menu_turret_selected() -> void:
	#add piercing turret
	var new_turret : Object = piercing_turret.instantiate()
	new_turret.position = Vector2((position.x*2+size.x)/2, (position.y*2+size.y)/2)
	get_tree().current_scene.add_child(new_turret)
	turret_menu.visible = false
	
	self.queue_free()
	
func _on_Ice_turret_menu_turret_selected() -> void:
	#add Ice turret
	var new_turret : Object = ice_turret.instantiate()
	new_turret.position = Vector2((position.x*2+size.x)/2, (position.y*2+size.y)/2)
	get_tree().current_scene.add_child(new_turret)
	turret_menu.visible = false
	
	self.queue_free()
	
func _on_Fire_turret_menu_turret_selected() -> void:
	#add Fire turret
	var new_turret : Object = fire_turret.instantiate()
	new_turret.position = Vector2((position.x*2+size.x)/2, (position.y*2+size.y)/2)
	get_tree().current_scene.add_child(new_turret)
	turret_menu.visible = false
	
	self.queue_free()
	
func _on_menu_timer_timeout() -> void:
	menu_timer.stop()
	if turret_menu.visible == true:
		turret_menu.visible = false
