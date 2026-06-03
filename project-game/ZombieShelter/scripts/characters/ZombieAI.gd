extends CharacterBody2D
class_name ZombieAI

## 僵尸 AI - 状态机驱动

# ----- 信号 -----
signal zombie_damaged(amount: int)
signal zombie_died()
signal zombie_attacked_player()

# ----- 状态枚举 -----
enum State { IDLE, PATROL, ALERTED, CHASING, ATTACKING, STUNNED, DEAD }

# ----- 导出属性 -----
@export var health: int = 4
@export var move_speed: float = 60.0
@export var chase_speed: float = 120.0
@export var damage: int = 15
@export var stun_time: float = 0.3
@export var detection_radius: float = 250.0  # 视野/发现玩家距离
@export var hearing_range: float = 350.0     # 听力范围
@export var attack_range: float = 32.0
@export var attack_cooldown: float = 1.2
@export var patrol_radius: float = 80.0
@export var max_health: int = 4

# ----- 内部状态 -----
var current_state: int = State.IDLE
var patrol_target: Vector2
var spawn_position: Vector2
var alert_position: Vector2
var chase_target: Node2D = null
var state_timer: float = 0.0
var attack_cooldown_timer: float = 0.0
var can_attack: bool = true
var facing_direction: Vector2 = Vector2.DOWN
var is_dead: bool = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var vision_area: Area2D = $VisionArea
@onready var attack_area: Area2D = $AttackArea

func _ready() -> void:
	add_to_group("zombie")
	spawn_position = global_position
	max_health = health
	patrol_target = get_random_patrol_point()
	_setup_sprite_frames()

	# 根据 detection_radius 动态设置视野碰撞体大小
	if vision_area:
		var vs: CollisionShape2D = vision_area.get_node_or_null("VisionShape") as CollisionShape2D
		if vs and vs.shape is RectangleShape2D:
			var rect: RectangleShape2D = vs.shape as RectangleShape2D
			var r: float = detection_radius
			rect.size = Vector2(r, r)
		# 确保监测开启
		vision_area.monitoring = true

	set_state(State.IDLE)


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	state_timer -= delta
	attack_cooldown_timer -= delta

	if not can_attack and attack_cooldown_timer <= 0:
		can_attack = true

	# 核心: 直接用距离检测玩家 (比 Area2D 信号可靠得多)
	_try_detect_player()

	match current_state:
		State.IDLE:
			process_idle(delta)
		State.PATROL:
			process_patrol(delta)
		State.ALERTED:
			process_alerted(delta)
		State.CHASING:
			process_chasing(delta)
		State.ATTACKING:
			process_attacking(delta)
		State.STUNNED:
			process_stunned(delta)

	update_animation()
	move_and_slide()


## 距离检测玩家 - 核心发现机制
func _try_detect_player() -> void:
	# 只在非战斗状态检测
	if current_state in [State.CHASING, State.ATTACKING, State.STUNNED, State.DEAD]:
		return

	var player: Node2D = get_nearest_player()
	if not player:
		return

	var dist: float = global_position.distance_to(player.global_position)
	if dist <= detection_radius:
		chase_target = player
		set_state(State.CHASING)


# ----- 状态处理 -----

func process_idle(_delta: float) -> void:
	velocity = Vector2.ZERO
	if state_timer <= 0:
		set_state(State.PATROL)
		state_timer = 2.0 + randf_range(0.0, 2.0)


func process_patrol(delta: float) -> void:
	var dir: Vector2 = (patrol_target - global_position)
	if dir.length() > 8.0:
		velocity = dir.normalized() * move_speed
		facing_direction = dir.normalized()
	else:
		if state_timer <= 0:
			patrol_target = get_random_patrol_point()
			state_timer = 1.0 + randf_range(0.0, 3.0)
		else:
			velocity = Vector2.ZERO


func process_alerted(delta: float) -> void:
	var dir: Vector2 = (alert_position - global_position)
	if dir.length() > 16.0:
		velocity = dir.normalized() * chase_speed
		facing_direction = dir.normalized()
	else:
		# 到达声源位置，转为巡逻
		set_state(State.PATROL)
		patrol_target = get_random_patrol_point()


func process_chasing(delta: float) -> void:
	if chase_target == null or not is_instance_valid(chase_target):
		set_state(State.PATROL)
		return

	var dir: Vector2 = (chase_target.global_position - global_position)
	var dist: float = dir.length()

	if dist <= attack_range:
		set_state(State.ATTACKING)
		return

	velocity = dir.normalized() * chase_speed
	facing_direction = dir.normalized()


func process_attacking(_delta: float) -> void:
	velocity = Vector2.ZERO

	if can_attack and chase_target and is_instance_valid(chase_target):
		var dist: float = global_position.distance_to(chase_target.global_position)
		if dist <= attack_range + 12.0:
			# 攻击玩家
			if chase_target.has_method("take_damage"):
				chase_target.take_damage(damage)
			zombie_attacked_player.emit()
			can_attack = false
			attack_cooldown_timer = attack_cooldown
		else:
			set_state(State.CHASING)
	elif chase_target == null or not is_instance_valid(chase_target):
		set_state(State.PATROL)


func process_stunned(_delta: float) -> void:
	velocity = Vector2.ZERO
	if state_timer <= 0:
		# 如果有追逐目标则追击
		if chase_target and is_instance_valid(chase_target):
			set_state(State.CHASING)
		else:
			set_state(State.PATROL)


# ----- 公共方法 -----

## 收到噪音通知
func hear_noise(noise_position: Vector2, _intensity: float) -> void:
	if is_dead or current_state == State.DEAD or current_state == State.STUNNED:
		return

	alert_position = noise_position
	set_state(State.ALERTED)


## 受到伤害
func take_damage(amount: int, attack_position: Vector2 = Vector2.ZERO) -> void:
	if is_dead:
		return

	health -= amount
	zombie_damaged.emit(amount)

	# 受到攻击立刻锁定玩家
	var player: Node = get_nearest_player()
	if player:
		chase_target = player

	# 硬直
	set_state(State.STUNNED)
	state_timer = stun_time

	if health <= 0:
		die()


func die() -> void:
	is_dead = true
	current_state = State.DEAD
	velocity = Vector2.ZERO
	collision_shape.set_deferred("disabled", true)
	zombie_died.emit()
	# 淡出消失
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.8)
	await tween.finished
	queue_free()


# ----- 辅助方法 -----

## 从精灵表加载僵尸动画
func _setup_sprite_frames() -> void:
	var sheet: Texture2D = load("res://resources/sprites/spritesheet.png")
	if not sheet:
		return

	var frames: SpriteFrames = SpriteFrames.new()
	var cell: int = 32
	var dirs: Array[String] = ["walk_down", "walk_left", "walk_right"]

	for d: int in range(3):
		frames.add_animation(dirs[d])
		frames.set_animation_loop(dirs[d], true)
		frames.set_animation_speed(dirs[d], 6.0)
		for f: int in range(4):
			var tex: AtlasTexture = AtlasTexture.new()
			tex.atlas = sheet
			tex.region = Rect2(f * cell, (d + 4) * cell, cell, cell)
			frames.add_frame(dirs[d], tex)

	animated_sprite.sprite_frames = frames
	animated_sprite.visible = true

func set_state(new_state: int) -> void:
	current_state = new_state
	match new_state:
		State.IDLE:
			state_timer = 2.0 + randf_range(0.0, 2.0)
		State.STUNNED:
			state_timer = stun_time


func get_random_patrol_point() -> Vector2:
	return spawn_position + Vector2(
		randf_range(-patrol_radius, patrol_radius),
		randf_range(-patrol_radius, patrol_radius)
	)


func get_nearest_player() -> Node2D:
	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return null
	return players[0] as Node2D


func update_animation() -> void:
	if is_dead:
		animated_sprite.play("death")
		return

	# 若无 SpriteFrames 资源，跳过动画播放
	if not animated_sprite.sprite_frames:
		return

	# 根据朝向选择动画方向
	var base: String = "walk_down"
	if abs(facing_direction.x) > abs(facing_direction.y):
		base = "walk_right" if facing_direction.x > 0 else "walk_left"
	elif facing_direction.y < 0:
		base = "walk_up"
	else:
		base = "walk_down"

	match current_state:
		State.IDLE, State.PATROL:
			if velocity.length() > 0:
				animated_sprite.play(base)
			else:
				animated_sprite.play(base)  # 用同方向的第一帧
				animated_sprite.stop()
		State.ALERTED, State.CHASING:
			animated_sprite.play(base)
		State.ATTACKING:
			animated_sprite.play(base)
		State.STUNNED:
			animated_sprite.play(base)
			animated_sprite.stop()

	# 翻转朝向
	if facing_direction.x != 0:
		animated_sprite.flip_h = facing_direction.x < 0


## Area2D 信号兜底 (玩家走入视野包围盒)
func _on_vision_area_body_entered(body: Node) -> void:
	if body.is_in_group("player") and current_state not in [State.CHASING, State.ATTACKING, State.STUNNED, State.DEAD]:
		chase_target = body
		set_state(State.CHASING)
