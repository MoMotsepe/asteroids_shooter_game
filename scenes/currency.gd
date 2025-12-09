# currency.gd
extends Node

signal currency_changed(id: StringName, new_value: int)

# Ledger keys
const PLUTONIUM:    StringName = &"plutonium"
const TITATERARIUM: StringName = &"titaterarium"

var _balances := {
	PLUTONIUM: 0,
	TITATERARIUM: 0,
}

func set_currency(id: StringName, value: int) -> void:
	_balances[id] = max(0, int(value))
	emit_signal("currency_changed", id, _balances[id])

func get_currency(id: StringName) -> int:
	return int(_balances.get(id, 0))

func add_currency(id: StringName, delta: int) -> void:
	set_currency(id, get_currency(id) + int(delta))

# Back-compat (old single-currency API = Plutonium)
func setCurrency(value: int) -> void: set_currency(PLUTONIUM, value)
func getCurrency() -> int: return get_currency(PLUTONIUM)
func addCurrency(value: int) -> void: add_currency(PLUTONIUM, value)
