extends PlayerBase
## Ham Warrior: Melee tank. Uses a meat hammer for wide swings.

func _ready() -> void:
	super()
	sprite.texture = SpriteGen.gen_ham_warrior()


func attack() -> void:
	# Melee sweep — Area2D cone in mouse direction
	var dir: Vector2 = get_mouse_direction()
	var swing_area: Area2D = Area2D.new()
	var collision: CollisionShape2D = CollisionShape2D.new()
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = Vector2(40, 30)
	collision.shape = shape
	collision.set_deferred("position", Vector2(25, 0))
	swing_area.add_child(collision)
	swing_area.rotation = dir.angle()
	swing_area.position = global_position + dir * 20

	# Visual swing effect
	var swing_sprite := Sprite2D.new()
	swing_sprite.texture = SpriteGen.gen_ham_warrior()
	swing_sprite.scale = Vector2(0.6, 0.6)
	swing_sprite.modulate = Color(1.0, 0.5, 0.5, 0.5)
	swing_area.add_child(swing_sprite)

	var hit_enemies: Array[Node] = []
	swing_area.area_entered.connect(func(area: Area2D) -> void:
		var parent: Node = area.get_parent()
		if parent and parent.is_in_group("enemies") and not hit_enemies.has(parent):
			if parent.has_method("take_damage"):
				parent.take_damage(attack_damage)
			hit_enemies.append(parent)
	)

	# Auto-remove after brief moment
	get_parent().add_child(swing_area)
	var remove_timer: Timer = Timer.new()
	remove_timer.wait_time = 0.2
	remove_timer.one_shot = true
	swing_area.add_child(remove_timer)
	remove_timer.start()
	remove_timer.timeout.connect(func() -> void:
		if is_instance_valid(swing_area):
			swing_area.queue_free()
	)

	start_attack_cooldown()
	EventBus.player_attack.emit()


func use_skill() -> void:
	# Charge: Dash forward, hitting first enemy for 30 damage + knockback
	var dir: Vector2 = get_mouse_direction()
	var charge_speed: float = 600.0
	var charge_duration: float = 0.3

	var original_speed: int = speed
	speed = ceili(charge_speed)
	var charge_tween: Tween = create_tween()
	charge_tween.tween_property(self, "speed", original_speed, charge_duration)

	# Check collision during charge
	var charge_area: Area2D = Area2D.new()
	var collision: CollisionShape2D = CollisionShape2D.new()
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = Vector2(36, 24)
	collision.shape = shape
	charge_area.add_child(collision)
	charge_area.position = Vector2(0, 0)

	var hit_enemies: Array[Node] = []
	charge_area.area_entered.connect(func(area: Area2D) -> void:
		var parent: Node = area.get_parent()
		if parent and parent.is_in_group("enemies") and not hit_enemies.has(parent):
			if parent.has_method("take_damage"):
				parent.take_damage(30)
			if parent.has_method("apply_knockback"):
				parent.apply_knockback(dir * 200.0)
			hit_enemies.append(parent)
	)

	add_child(charge_area)

	# Visual charge effect
	modulate = Color(1.0, 0.6, 0.6, 1.0)

	var remove_timer: Timer = Timer.new()
	remove_timer.wait_time = 0.4
	remove_timer.one_shot = true
	add_child(remove_timer)
	remove_timer.start()
	remove_timer.timeout.connect(func() -> void:
		if is_instance_valid(charge_area):
			charge_area.queue_free()
		if is_instance_valid(self):
			modulate = Color.WHITE
	)

	start_skill_cooldown()
	EventBus.player_skill_used.emit("Charge")
