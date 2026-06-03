extends Node
## GameManager: Global game state, difficulty scaling, and scene transitions.

enum CharacterType { BUTTER_SHOOTER, HAM_WARRIOR, LETTUCE_PRIEST }

var character_type: int = CharacterType.BUTTER_SHOOTER
var current_floor: int = 1
var current_room: int = 1
var rooms_until_boss: int = 5
var difficulty_multiplier: float = 1.0

var player_hp: int = 80
var player_max_hp: int = 80
var player_speed: int = 280
var player_attack_damage: int = 12
var player_defense: int = 0

var potion_count: int = 0
var attack_bonus: int = 0
var defense_bonus: int = 0
var speed_bonus: int = 0

var is_game_over: bool = false
var is_boss_room: bool = false


func start_game(char_type: int) -> void:
	character_type = char_type
	current_floor = 1
	current_room = 1
	difficulty_multiplier = 1.0
	is_game_over = false
	rooms_until_boss = 5

	match char_type:
		CharacterType.BUTTER_SHOOTER:
			player_hp = 80
			player_max_hp = 80
			player_speed = 280
			player_attack_damage = 12
		CharacterType.HAM_WARRIOR:
			player_hp = 180
			player_max_hp = 180
			player_speed = 220
			player_attack_damage = 20
		CharacterType.LETTUCE_PRIEST:
			player_hp = 100
			player_max_hp = 100
			player_speed = 240
			player_attack_damage = 8

	player_defense = 0
	potion_count = 0
	attack_bonus = 0
	defense_bonus = 0
	speed_bonus = 0
	is_boss_room = false

	EventBus.game_started.emit(["butter_shooter", "ham_warrior", "lettuce_priest"][char_type])


func next_room() -> void:
	current_room += 1
	rooms_until_boss -= 1
	if rooms_until_boss <= 0:
		rooms_until_boss = 5
		next_floor()
	else:
		is_boss_room = false
		EventBus.room_entered.emit(current_room, current_floor)


func next_floor() -> void:
	current_floor += 1
	difficulty_multiplier = 1.0 + (current_floor - 1) * 0.2
	is_boss_room = true
	EventBus.floor_changed.emit(current_floor)
	EventBus.room_entered.emit(current_room, current_floor)


func get_scaled_hp(base_hp: int) -> int:
	return ceili(base_hp * difficulty_multiplier)


func get_scaled_damage(base_damage: int) -> int:
	return ceili(base_damage * difficulty_multiplier)


func get_scaled_speed(base_speed: int) -> int:
	return ceili(base_speed * difficulty_multiplier)
