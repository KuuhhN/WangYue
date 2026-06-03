extends CanvasLayer
## Game Over / Victory screen.

var is_victory: bool = false

@onready var title_label: Label = $VBoxContainer/TitleLabel
@onready var info_label: Label = $VBoxContainer/InfoLabel
@onready var restart_button: Button = $VBoxContainer/RestartButton
@onready var menu_button: Button = $VBoxContainer/MenuButton


func _ready() -> void:
	EventBus.victory.connect(func() -> void:
		is_victory = true
		title_label.text = "🎉 VICTORY!"
		title_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.0))
		info_label.text = "You conquered the dungeon!\nFloor reached: %d" % GameManager.current_floor
	)

	EventBus.game_over.connect(_on_game_over)
	restart_button.pressed.connect(_on_restart)
	menu_button.pressed.connect(_on_menu)


func _on_game_over() -> void:
	if not is_victory:
		title_label.text = "💀 GAME OVER"
		title_label.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2))
		info_label.text = "You fell in battle...\nFloor reached: %d\nRoom reached: %d" % [GameManager.current_floor, GameManager.current_room]


func _on_restart() -> void:
	GameManager.start_game(GameManager.character_type)
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
