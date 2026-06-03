extends Node
## EventBus: Global signal hub for decoupled communication.
## All game-wide signals are defined here to avoid circular dependencies.

signal player_damaged(new_hp: int, max_hp: int)
signal player_healed(new_hp: int, max_hp: int)
signal player_died()
signal player_attack()
signal player_skill_used(skill_name: String)

signal room_cleared()
signal room_entered(room_number: int, floor: int)
signal floor_changed(floor: int)

signal enemy_killed(enemy_type: String, position: Vector2)
signal boss_defeated()

signal item_collected(item_name: String, rarity: String)
signal chest_opened(position: Vector2)

signal game_started(character_type: String)
signal game_over()
signal victory()

signal damage_dealt(amount: int, target_position: Vector2, color: Color)
