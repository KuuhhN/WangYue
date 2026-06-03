extends CanvasLayer
## HUD: Displays player HP, floor/room info, and item effects.

@onready var hp_label: Label = $HBoxContainer/HPContainer/HPLabel
@onready var hp_bar: TextureProgressBar = $HBoxContainer/HPContainer/HPBar
@onready var floor_label: Label = $HBoxContainer/InfoContainer/FloorLabel
@onready var room_label: Label = $HBoxContainer/InfoContainer/RoomLabel
@onready var buff_label: Label = $HBoxContainer/BuffContainer/BuffLabel
@onready var char_name_label: Label = $HBoxContainer/CharNameLabel


func _ready() -> void:
	EventBus.player_damaged.connect(_on_player_damaged)
	EventBus.player_healed.connect(_on_player_healed)
	EventBus.room_entered.connect(_on_room_entered)
	EventBus.floor_changed.connect(_on_floor_changed)
	EventBus.game_started.connect(_on_game_started)
	EventBus.item_collected.connect(_on_item_collected)
	_update_hp_display()


func _on_game_started(char_type: String) -> void:
	var name_map: Dictionary = {
		"butter_shooter": "🧈 Butter Shooter",
		"ham_warrior": "🥩 Ham Warrior",
		"lettuce_priest": "🥬 Lettuce Priest"
	}
	char_name_label.text = name_map.get(char_type, char_type)
	_update_hp_display()


func _on_player_damaged(new_hp: int, max_hp: int) -> void:
	hp_label.text = "HP: %d/%d" % [new_hp, max_hp]
	hp_bar.value = (float(new_hp) / float(max_hp)) * 100.0
	hp_bar.modulate = Color.RED
	var tween: Tween = create_tween()
	tween.tween_property(hp_bar, "modulate", Color.WHITE, 0.3)


func _on_player_healed(new_hp: int, max_hp: int) -> void:
	hp_label.text = "HP: %d/%d" % [new_hp, max_hp]
	hp_bar.value = (float(new_hp) / float(max_hp)) * 100.0
	hp_bar.modulate = Color(0.5, 1.0, 0.5)
	var tween: Tween = create_tween()
	tween.tween_property(hp_bar, "modulate", Color.WHITE, 0.3)


func _on_room_entered(room_num: int, floor_num: int) -> void:
	room_label.text = "Room: %d" % room_num
	floor_label.text = "Floor: %d" % floor_num

func _on_floor_changed(floor_num: int) -> void:
	floor_label.text = "Floor: %d" % floor_num
	hp_bar.modulate = Color(0.5, 0.8, 1.0)
	var tween: Tween = create_tween()
	tween.tween_property(hp_bar, "modulate", Color.WHITE, 0.5)


func _on_item_collected(item_name: String, rarity: String) -> void:
	var color_map: Dictionary = {
		"Common": "#FFFFFF",
		"Rare": "#5588FF",
		"Epic": "#BB44EE"
	}
	var color: String = color_map.get(rarity, "#FFFFFF")
	var msg: String = "[color=%s]%s %s[/color]" % [color, rarity, item_name]
	buff_label.text = msg

	# Flash and fade
	var tween: Tween = create_tween()
	tween.tween_property(buff_label, "modulate:a", 0.0, 2.0)
	tween.tween_callback(func() -> void:
		if is_instance_valid(buff_label):
			buff_label.text = ""
	)


func _update_hp_display() -> void:
	hp_label.text = "HP: %d/%d" % [GameManager.player_hp, GameManager.player_max_hp]
	hp_bar.max_value = 100.0
	hp_bar.value = (float(GameManager.player_hp) / float(GameManager.player_max_hp)) * 100.0
