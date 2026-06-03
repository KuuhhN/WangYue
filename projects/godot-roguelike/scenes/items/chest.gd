extends Area2D
## Chest: Contains 1-3 potions. Opened on player contact.

class_name Chest

var is_opened: bool = false
var potion_count: int = 1

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	sprite.texture = SpriteGen.gen_chest()
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body is PlayerBase and not is_opened:
		is_opened = true
		_open()


func _open() -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	potion_count = rng.randi_range(1, 3)

	var item_scene: PackedScene = preload("res://scenes/items/item_base.tscn")

	for i in range(potion_count):
		var item: ItemBase = item_scene.instantiate()
		item.potion_type = rng.randi_range(0, 3)
		# Rarity: common 60%, rare 30%, epic 10%
		var rarity_roll: int = rng.randi_range(0, 99)
		if rarity_roll < 60:
			item.rarity = ItemBase.Rarity.COMMON
		elif rarity_roll < 90:
			item.rarity = ItemBase.Rarity.RARE
		else:
			item.rarity = ItemBase.Rarity.EPIC

		var offset: Vector2 = Vector2(rng.randf_range(-20, 20), rng.randf_range(-20, 20))
		item.position = position + offset

		var parent: Node = get_parent()
		if parent:
			parent.add_child(item)

	EventBus.chest_opened.emit(position)

	# Visual: opened chest
	sprite.modulate = Color(0.6, 0.35, 0.15)
