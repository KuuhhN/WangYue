extends Node2D
## Main game scene controller. Sets up player, room, HUD.

func _ready() -> void:
	# Set up HUD
	var hud_scene: PackedScene = preload("res://scenes/ui/hud.tscn")
	var hud: CanvasLayer = hud_scene.instantiate()
	add_child(hud)

	# Set up room manager
	var room_manager_scene: PackedScene = preload("res://scenes/room_manager.tscn")
	var room_manager: Node2D = room_manager_scene.instantiate()
	add_child(room_manager)

	# Spawn player — instantiate base scene, then override script with character type
	var player_scene: PackedScene = preload("res://scenes/player.tscn")
	var player: PlayerBase = player_scene.instantiate()

	var char_script: Script
	match GameManager.character_type:
		GameManager.CharacterType.BUTTER_SHOOTER:
			char_script = preload("res://scenes/characters/butter_shooter.gd")
		GameManager.CharacterType.HAM_WARRIOR:
			char_script = preload("res://scenes/characters/ham_warrior.gd")
		GameManager.CharacterType.LETTUCE_PRIEST:
			char_script = preload("res://scenes/characters/lettuce_priest.gd")

	player.set_script(char_script)

	player.position = Vector2(
		room_manager.room_width_px / 2,
		room_manager.room_height_px - 2 * room_manager.TILE_SIZE
	)
	player.add_to_group("player")
	add_child(player)

	# Generate first room
	room_manager.generate_room(1, false)

	# Notify
	EventBus.room_entered.emit(1, 1)
