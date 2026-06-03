extends Area2D
## Base item class. All consumable items inherit from this.

class_name ItemBase

enum PotionType { HEALTH, ATTACK, DEFENSE, SPEED }
enum Rarity { COMMON, RARE, EPIC }

@export var potion_type: int = PotionType.HEALTH
@export var rarity: int = Rarity.COMMON

var potion_name: String = "Health Potion"

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	_setup_potion()
	body_entered.connect(_on_body_entered)


func _setup_potion() -> void:
	var rarity_colors: Dictionary = {
		Rarity.COMMON: Color(1, 1, 1),
		Rarity.RARE: Color(0.3, 0.5, 1.0),
		Rarity.EPIC: Color(0.7, 0.3, 0.9)
	}

	match potion_type:
		PotionType.HEALTH:
			sprite.texture = SpriteGen.gen_health_potion()
			potion_name = "Health Potion"
		PotionType.ATTACK:
			sprite.texture = SpriteGen.gen_attack_potion()
			potion_name = "Attack Potion"
		PotionType.DEFENSE:
			sprite.texture = SpriteGen.gen_defense_potion()
			potion_name = "Defense Potion"
		PotionType.SPEED:
			sprite.texture = SpriteGen.gen_speed_potion()
			potion_name = "Speed Potion"

	modulate = rarity_colors.get(rarity, Color.WHITE)


func _on_body_entered(body: Node2D) -> void:
	if body is PlayerBase:
		_apply_effect(body)
		EventBus.item_collected.emit(potion_name, ["Common", "Rare", "Epic"][rarity])
		queue_free()


func _apply_effect(player: PlayerBase) -> void:
	var effect_mult: float = 1.0
	match rarity:
		Rarity.RARE:
			effect_mult = 1.5
		Rarity.EPIC:
			effect_mult = 2.5

	match potion_type:
		PotionType.HEALTH:
			var heal_amount: int = ceili(20 * effect_mult)
			player.heal(heal_amount)
		PotionType.ATTACK:
			var bonus: int = ceili(5 * effect_mult)
			player.attack_damage += bonus
			GameManager.attack_bonus += bonus
		PotionType.DEFENSE:
			var bonus: int = ceili(3 * effect_mult)
			player.defense_bonus += bonus
			GameManager.defense_bonus += bonus
		PotionType.SPEED:
			var bonus: int = ceili(15 * effect_mult)
			player.speed_bonus += bonus
			GameManager.speed_bonus += bonus
