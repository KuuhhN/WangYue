extends CharacterBody2D
## Base enemy class. All enemy types share this structure.

class_name EnemyBase

enum EnemyType { MOLD_SLIME, SPICY_GHOST, CHEESE_DEMON, BOSS }

@export var enemy_type: int = EnemyType.MOLD_SLIME
@export var hp: int = 120
@export var move_speed: float = 60.0
@export var collision_damage: int = 15
@export var experience_value: int = 10

var max_hp: int = 120
var player_ref: Node2D = null
var is_slowed: bool = false
var slow_timer: float = 0.0
var slow_factor: float = 1.0
var is_attacking: bool = false
var is_boss: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var hitbox_collision: CollisionShape2D = $Hitbox/HitboxShape
@onready var attack_cooldown: Timer = $AttackCooldown


func _ready() -> void:
	max_hp = hp
	_add_to_group("enemies")
	_setup_type()
	attack_cooldown.wait_time = 0.5
	_scale_difficulty()


func _scale_difficulty() -> void:
	hp = GameManager.get_scaled_hp(hp)
	max_hp = hp
	collision_damage = GameManager.get_scaled_damage(collision_damage)
	move_speed = GameManager.get_scaled_speed(ceili(move_speed))


func _setup_type() -> void:
	match enemy_type:
		EnemyType.MOLD_SLIME:
			sprite.texture = SpriteGen.gen_enemy_mold_slime()
			sprite.scale = Vector2(1, 1)
		EnemyType.SPICY_GHOST:
			sprite.texture = SpriteGen.gen_enemy_spicy_ghost()
			sprite.scale = Vector2(1, 1)
		EnemyType.CHEESE_DEMON:
			sprite.texture = SpriteGen.gen_enemy_cheese_demon()
			sprite.scale = Vector2(1, 1)
		EnemyType.BOSS:
			sprite.texture = SpriteGen.gen_enemy_boss()
			sprite.scale = Vector2(1.5, 1.5)
			is_boss = true


func _find_player() -> Node2D:
	if player_ref and is_instance_valid(player_ref):
		return player_ref
	player_ref = get_tree().get_first_node_in_group("player")
	return player_ref


func _physics_process(delta: float) -> void:
	if GameManager.is_game_over:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var player: Node2D = _find_player()
	if not player:
		return

	# Slow timer
	if is_slowed:
		slow_timer -= delta
		if slow_timer <= 0:
			is_slowed = false
			slow_factor = 1.0

	# Movement
	var dir: Vector2 = (player.global_position - global_position).normalized()
	var current_speed: float = move_speed * slow_factor
	velocity = dir * current_speed
	move_and_slide()

	# Boss fires projectiles
	if is_boss and not is_attacking:
		_boss_attack()


func _boss_attack() -> void:
	if not _find_player():
		return
	is_attacking = true
	attack_cooldown.start()

	# Fire spread shot - 5 bullets in a fan
	var base_dir: Vector2 = (player_ref.global_position - global_position).normalized()
	var spread_angle: float = PI / 4  # 45 degree spread
	for i in range(5):
		var angle_offset: float = spread_angle * (i - 2) / 4.0
		var bullet_dir: Vector2 = base_dir.rotated(angle_offset)
		var bullet_scene: PackedScene = preload("res://scenes/bullet.tscn")
		var bullet: Area2D = bullet_scene.instantiate()
		bullet.position = global_position + bullet_dir * 20.0
		bullet.set_direction(bullet_dir)
		bullet.set_damage(12)
		bullet.is_enemy_bullet = true
		bullet.bullet_color = Color(0.7, 0.2, 0.7)
		bullet.scale = Vector2(1.2, 1.2)
		get_parent().add_child(bullet)

	attack_cooldown.wait_time = 2.0 - minf(1.5, GameManager.difficulty_multiplier * 0.2)


func take_damage(amount: int) -> void:
	hp -= amount
	sprite.modulate = Color(1.0, 0.5, 0.5)
	var tween: Tween = create_tween()
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)
	EventBus.damage_dealt.emit(amount, global_position, Color.YELLOW)

	if hp <= 0:
		die()


func apply_slow(factor: float, duration: float) -> void:
	is_slowed = true
	slow_factor = factor
	slow_timer = duration
	sprite.modulate = Color(0.6, 0.6, 1.0)
	var tween: Tween = create_tween()
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.2).set_delay(duration)


func apply_knockback(force: Vector2) -> void:
	var tween: Tween = create_tween()
	var target: Vector2 = global_position + force
	tween.tween_property(self, "global_position", target, 0.2)


func die() -> void:
	var enemy_name: String = ["Mold Slime", "Spicy Ghost", "Cheese Demon", "Boss"][enemy_type]
	EventBus.enemy_killed.emit(enemy_name, global_position)
	if is_boss:
		EventBus.boss_defeated.emit()
	queue_free()


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body is PlayerBase:
		body.take_damage(collision_damage)


func _on_attack_cooldown_timeout() -> void:
	is_attacking = false


func _exit_tree() -> void:
	# Check if all enemies in room are dead (skip during room regeneration)
	if not get_tree():
		return
	var enemies: Array[Node] = get_tree().get_nodes_in_group("enemies")
	# If we're the last one and the room isn't being regenerated
	var any_left: bool = false
	for e in enemies:
		if is_instance_valid(e) and e != self:
			any_left = true
			break
	if not any_left and not GameManager.is_game_over:
		EventBus.room_cleared.emit()
