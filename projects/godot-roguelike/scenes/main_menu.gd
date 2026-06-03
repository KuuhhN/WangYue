extends CanvasLayer
## Main Menu: Character selection screen.

@onready var title_label: Label = $VBoxContainer/TitleLabel
@onready var char_description: Label = $VBoxContainer/CharDescription
@onready var start_button: Button = $VBoxContainer/StartButton
@onready var butter_button: Button = $VBoxContainer/CharSelect/ButterButton
@onready var ham_button: Button = $VBoxContainer/CharSelect/HamButton
@onready var lettuce_button: Button = $VBoxContainer/CharSelect/LettuceButton

var selected_char: int = GameManager.CharacterType.BUTTER_SHOOTER

var char_data: Dictionary = {
	0: {
		"name": "🧈 Butter Shooter",
		"desc": "Ranged DPS\nHP: 80 | Speed: 280\nAttack: Butter Bullet (12 dmg, 0.6s)\nSkill: Butter Slide (slow enemies 50% for 3s)"
	},
	1: {
		"name": "🥩 Ham Warrior",
		"desc": "Melee Tank\nHP: 180 | Speed: 220\nAttack: Meat Hammer (20 dmg, 1.0s)\nSkill: Charge (dash + 30 dmg + knockback)"
	},
	2: {
		"name": "🥬 Lettuce Priest",
		"desc": "Ranged Support\nHP: 100 | Speed: 240\nAttack: Lettuce Dart (8 dmg, 0.8s)\nSkill: Heal (40 + DOT 5HP/s for 5s)"
	}
}


func _ready() -> void:
	butter_button.pressed.connect(_select_butter)
	ham_button.pressed.connect(_select_ham)
	lettuce_button.pressed.connect(_select_lettuce)
	start_button.pressed.connect(_start_game)
	_select_butter()


func _select_butter() -> void:
	selected_char = GameManager.CharacterType.BUTTER_SHOOTER
	var data: Dictionary = char_data[selected_char]
	title_label.text = data["name"]
	char_description.text = data["desc"]
	_reset_button_colors()
	butter_button.modulate = Color(1.0, 0.85, 0.0)


func _select_ham() -> void:
	selected_char = GameManager.CharacterType.HAM_WARRIOR
	var data: Dictionary = char_data[selected_char]
	title_label.text = data["name"]
	char_description.text = data["desc"]
	_reset_button_colors()
	ham_button.modulate = Color(1.0, 0.6, 0.6)


func _select_lettuce() -> void:
	selected_char = GameManager.CharacterType.LETTUCE_PRIEST
	var data: Dictionary = char_data[selected_char]
	title_label.text = data["name"]
	char_description.text = data["desc"]
	_reset_button_colors()
	lettuce_button.modulate = Color(0.4, 0.9, 0.4)


func _reset_button_colors() -> void:
	butter_button.modulate = Color.WHITE
	ham_button.modulate = Color.WHITE
	lettuce_button.modulate = Color.WHITE


func _start_game() -> void:
	GameManager.start_game(selected_char)
	get_tree().change_scene_to_file("res://scenes/game.tscn")
