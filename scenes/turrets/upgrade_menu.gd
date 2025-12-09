# menu for turret upgrading
extends TextureRect

@onready var upgrade_level: Button = $ScrollContainer/VBoxContainer/UpgradeLevel
@onready var turret_type: Label = $TurretType
@onready var turret_level: Label = $TurretLevel
signal Upgraded
signal DeleteTurret

var type: int = 1 : set = setType, get = getType
var level: int = 1 : set = setLevel, get = getLevel

# --- COST SYSTEM ---
@export var base_cost: int = 5            # cost from L1->L2
@export var growth_factor: float = 2   # multiplicative growth per level
@export var max_level: int = 100          # set <= 0 for no cap

func _ready() -> void:
	# paint turret type

	_refresh_level_ui()
	_refresh_button()

func _process(_delta: float) -> void:
	_refresh_button()

# --- Public getters/setters ---
func setType(value: int) -> void:
	type = value
	match type:
		1: turret_type.text = "Regular TURRET"
		2: turret_type.text = "PIERCING TURRET"
		3: turret_type.text = "FIRE TURRET"
		4: turret_type.text = "ICE TURRET"

func getType() -> int:
	return type

func setLevel(value: int) -> void:
	level = value
	_refresh_level_ui()
	_refresh_button()

func getLevel() -> int:
	return level

# --- Cost helpers ---
func get_current_cost() -> int:
	var exponent: int = max(level - 1, 0)
	var cost: int = int(round(float(base_cost) * pow(growth_factor, float(exponent))))
	return  max(cost, 1)

func can_upgrade() -> bool:
	if max_level > 0 and level >= max_level:
		return false
	var available: int 
	if getType() == 1:
		available = _get_plutonium()
	else:
		available = _get_TITATERARIUM()
	return available >= get_current_cost()

# --- UI refreshers ---
func _refresh_level_ui() -> void:
	turret_level.text = "LEVEL " + str(level)

func _refresh_button() -> void:
	var cost: int = get_current_cost()

	if max_level > 0 and level >= max_level:
		upgrade_level.text = "MAX LEVEL"
		upgrade_level.disabled = true
		return

	if getType() == 1:
		upgrade_level.text = "LEVEL " + str(level + 1) + "\n" + str(cost) + " PLUTONIUM"
		upgrade_level.disabled = (_get_plutonium() < cost)
	else:
		upgrade_level.text = "LEVEL " + str(level + 1) + "\n" + str(cost) + " TITATERARIUM"
		upgrade_level.disabled = (_get_TITATERARIUM() < cost)

# --- Click handler ---
func _on_upgrade_level_pressed() -> void:
	var cost: int
	if getType() == 1:
		cost = get_current_cost()
		if max_level > 0 and level >= max_level:
			return
		if _get_plutonium() < cost:
			return
			
		if "add_currency" in Currency and "PLUTONIUM" in Currency:
			Currency.add_currency(Currency.PLUTONIUM, -cost)
		else:
			Currency.addCurrency(-cost)
	else:
		cost = get_current_cost()
		if max_level > 0 and level >= max_level:
			return
		if _get_TITATERARIUM() < cost:
			return
			
		if "add_currency" in Currency and "TITATERARIUM" in Currency:
			Currency.add_currency(Currency.TITATERARIUM, -cost)
		else:
			Currency.addCurrency(-cost)
	
	

	level += 1
	_refresh_level_ui()
	_refresh_button()

	Upgraded.emit()
	queue_free()

# --- Currency access (compat shim) ---
func _get_plutonium() -> int:
	if "get_currency" in Currency and "PLUTONIUM" in Currency:
		return int(Currency.get_currency(Currency.PLUTONIUM))
	return int(Currency.getCurrency())
	
func _get_TITATERARIUM() -> int:
	if "get_currency" in Currency and "TITATERARIUM" in Currency:
		return int(Currency.get_currency(Currency.TITATERARIUM))
	return int(Currency.getCurrency())


func _on_delete_turretbtn_pressed() -> void:
	emit_signal("DeleteTurret")
