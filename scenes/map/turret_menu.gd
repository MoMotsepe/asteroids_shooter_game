#turret selection menu
extends TextureRect

@onready var normal_turret: Button = $ScrollContainer/VBoxContainer/NormalTurret
@onready var piercing_turret: Button = $ScrollContainer/VBoxContainer/PiercingTurret
@onready var ice_turret: Button = $ScrollContainer/VBoxContainer/IceTurret
@onready var fire_turret: Button = $ScrollContainer/VBoxContainer/FireTurret

signal TurretSelected
signal PiercingTurretSelected
signal IceTurretSelected
signal FireTurretSelected
var available_currency : int

func _process(_delta: float) -> void:
	available_currency = Currency.getCurrency()
	
	if (available_currency < 5):
		normal_turret.disabled = true
	else:
		normal_turret.disabled = false
	if (Currency.get_currency(Currency.TITATERARIUM) < 2):
		piercing_turret.disabled = true
	else:
		piercing_turret.disabled = false
	if (Currency.get_currency(Currency.TITATERARIUM) < 5):
		ice_turret.disabled = true
		fire_turret.disabled = true
	else:
		ice_turret.disabled = false
		fire_turret.disabled = false

# normal turret
func _on_normal_turret_pressed() -> void:
	Currency.addCurrency(-5)
	TurretSelected.emit()

# piercing turret
func _on_piercing_turret_pressed() -> void:
	Currency.add_currency(Currency.TITATERARIUM, -2)
	PiercingTurretSelected.emit()

# ice turret
func _on_ice_turret_pressed() -> void:
	Currency.add_currency(Currency.TITATERARIUM, -5)
	IceTurretSelected.emit()

# fire turret
func _on_fire_turret_pressed() -> void:
	Currency.add_currency(Currency.TITATERARIUM, -5)
	FireTurretSelected.emit()
