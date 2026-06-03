extends PlayerBase
## Butter Shooter: Ranged attacker. Fires butter bullets.

func _ready() -> void:
	super()
	sprite.texture = SpriteGen.gen_butter_shooter()


func attack() -> void:
	var dir: Vector2 = get_mouse_direction()
	var bullet_scene: PackedScene = preload("res://scenes/bullet.tscn")
	var bullet: Area2D = bullet_scene.instantiate()
	bullet.position = global_position + dir * 20.0
	bullet.set_direction(dir)
	bullet.set_damage(attack_damage)
	bullet.bullet_color = Color(1.0, 0.85, 0.0)  # Butter yellow
	get_parent().add_child(bullet)
	start_attack_cooldown()
	EventBus.player_attack.emit()


func use_skill() -> void:
	# Butter Slide: Drop butter on floor, slowing enemies for 3s
	var dir: Vector2 = get_mouse_direction()
	var butter_area: Area2D = Area2D.new()
	var collision: CollisionShape2D = CollisionShape2D.new()
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = Vector2(60, 60)
	collision.shape = shape
	butter_area.add_child(collision)
	butter_area.position = global_position + dir * 40

	# Visual butter puddle
	var butter_sprite := Sprite2D.new()
	butter_sprite.texture = SpriteGen.gen_bullet()
	butter_sprite.scale = Vector2(3, 3)
	butter_sprite.modulate = Color(1.0, 0.9, 0.2, 0.6)
	butter_area.add_child(butter_sprite)

	butter_area.body_entered.connect(func(body: Node) -> void:
		if body.is_in_group("enemies"):
			if body.has_method("apply_slow"):
				body.apply_slow(0.5, 3.0)
	)
	get_parent().add_child(butter_area)

	# Auto-remove after 3 seconds
	var remove_timer: Timer = Timer.new()
	remove_timer.wait_time = 3.0
	remove_timer.one_shot = true
	butter_area.add_child(remove_timer)
	remove_timer.start()
	remove_timer.timeout.connect(func() -> void:
		if is_instance_valid(butter_area):
			butter_area.queue_free()
	)

	start_skill_cooldown()
	EventBus.player_skill_used.emit("Butter Slide")


func get_mouse_direction() -> Vector2:
	return (get_global_mouse_position() - global_position).normalized()
