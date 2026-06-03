extends PlayerBase
## Lettuce Priest: Ranged support. Fires lettuce darts and heals.

func _ready() -> void:
	super()
	sprite.texture = SpriteGen.gen_lettuce_priest()
	# Lower attack cooldown for lettuce
	attack_timer.wait_time = 0.8


func attack() -> void:
	# Lettuce leaf projectile
	var dir: Vector2 = get_mouse_direction()
	var bullet_scene: PackedScene = preload("res://scenes/bullet.tscn")
	var bullet: Area2D = bullet_scene.instantiate()
	bullet.position = global_position + dir * 20.0
	bullet.set_direction(dir)
	bullet.set_damage(attack_damage)
	bullet.bullet_color = Color(0.2, 0.8, 0.2)  # Lettuce green
	get_parent().add_child(bullet)
	start_attack_cooldown()
	EventBus.player_attack.emit()


func use_skill() -> void:
	# Healing Green Light: Heal 40 HP instantly + 5 HP/s for 5s
	var heal_amount: int = 40
	heal(heal_amount)

	# Visual heal effect
	var heal_sprite := Sprite2D.new()
	heal_sprite.texture = SpriteGen.gen_lettuce_projectile()
	heal_sprite.scale = Vector2(3, 3)
	heal_sprite.modulate = Color(0.2, 1.0, 0.2, 0.5)
	heal_sprite.position = Vector2(0, -20)
	add_child(heal_sprite)

	# Fade out heal visual
	var tween: Tween = create_tween()
	tween.tween_property(heal_sprite, "modulate:a", 0.0, 1.0)
	tween.tween_callback(func() -> void:
		if is_instance_valid(heal_sprite):
			heal_sprite.queue_free()
	)

	# DOT heal over 5s
	var dot_timer: Timer = Timer.new()
	dot_timer.wait_time = 1.0
	dot_timer.one_shot = false
	dot_timer.autostart = false
	var ticks: int = 0
	dot_timer.timeout.connect(func() -> void:
		ticks += 1
		if ticks <= 5:
			heal(5)
		else:
			if is_instance_valid(dot_timer):
				dot_timer.queue_free()
	)
	add_child(dot_timer)
	dot_timer.start()

	start_skill_cooldown()
	EventBus.player_skill_used.emit("Healing Green Light")


func _on_game_over() -> void:
	super()
	var children := get_children()
	for child in children:
		if child is Timer:
			child.queue_free()
