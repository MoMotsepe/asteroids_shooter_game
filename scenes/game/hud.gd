extends Control
class_name  HUD

@export var currency_label : Label
@export var Test_cur_Label : Label
@export var currency : int =0
@export var titaterarium_label: Label


#updates currency
func update_currency():
	currency = Currency.getCurrency()
	currency_label.text = str(currency) + " : Plutonium"

func update_titaterarium():
	if titaterarium_label:
		var t: int = 0
		if "get_currency" in Currency and "TITATERARIUM" in Currency:
			t = int(Currency.get_currency(Currency.TITATERARIUM))
		titaterarium_label.text = str(t) + " : Titaterarium"

func current_currency() -> int:
	return currency
	
func cur_label_test():
	Test_cur_Label.text = str(Currency.getCurrency())

func _process(_delta: float) -> void:
	call_deferred("update_currency")
	call_deferred("cur_label_test")
	call_deferred("update_titaterarium")
