extends CharacterBody2D
class_name PlayerController

## 玩家控制器 - 移动/交互/攻击

# ----- 信号 -----
signal spawned_noise(noise_position: Vector2, intensity: float)
signal performed_attack(attack_position: Vector2)
signal player_hurt(amount: int)
signal movement_mode_changed(mode: int)
signal interacted_with(target: Node)

# ----- 移动模式枚举 -----
enum MovementMode { CROUCH, WALK, RUN }
const MODE_SPEEDS: Dictionary = {
	MovementMode.CROUCH: 60.0,
	MovementMode.WALK: 120.0,
	MovementMode.RUN: 200.0
}

# ----- 导出属性 -----
@export var max_health: int = 100
@export var max_stamina: float = 100.0
@export var stamina_drain_rate: float = 15.0   # 奔跑每秒消耗
@export var stamina_regen_rate: float = 8.0    # 回复速率
@export var stamina_regen_crouch_bonus: float = 5.0  # 蹲伏额外回复
@export var attack_stamina_cost: float = 15.0
@export var attack_cooldown: float = 0.5
@export var move_while_attacking: bool = false

# ----- 内部状态 -----
var current_mode: int = MovementMode.WALK
var current_health: int = max_health
var current_stamina: float = max_stamina
var is_attacking: bool = false
var attack_timer: float = 0.0
var can_attack: bool = true
var facing_direction: Vector2 = Vector2.DOWN
var is_dead: bool = false
var _f_was_down: bool = false  # F 键边缘检测

# 组件引用
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var melee_system: MeleeSystem = $MeleeSystem
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var interaction_area: Area2D = $InteractionArea

func _ready() -> void:
	add_to_group("player")
	current_health = max_health
	current_stamina = max_stamina
	_setup_sprite_frames()


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	handle_movement(delta)
	handle_stamina(delta)
	handle_attack(delta)
	handle_interaction()
	update_animation()

	move_and_slide()


func handle_movement(delta: float) -> void:
	# 处理移动模式切换
	if Input.is_action_pressed("run") and current_stamina > 0 and not is_attacking:
		set_movement_mode(MovementMode.RUN)
	elif Input.is_action_pressed("crouch"):
		set_movement_mode(MovementMode.CROUCH)
	else:
		set_movement_mode(MovementMode.WALK)

	# 战斗状态限制
	if is_attacking and not move_while_attacking:
		velocity = Vector2.ZERO
		return

	# WASD / 方向键 输入 (双路检测确保可靠)
	var input_dir: Vector2 = Vector2.ZERO
	var input_h: float = Input.get_axis("move_left", "move_right")
	var input_v: float = Input.get_axis("move_up", "move_down")

	# 直接按键检测作为兜底 (支持方向键)
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		input_h = -1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		input_h = 1.0
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		input_v = -1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		input_v = 1.0

	input_dir = Vector2(input_h, input_v).normalized()
	velocity = input_dir * MODE_SPEEDS[current_mode]

	# 记录朝向
	if input_dir != Vector2.ZERO:
		facing_direction = input_dir

	# 移动时产生噪音
	if input_dir != Vector2.ZERO and current_mode == MovementMode.RUN:
		spawned_noise.emit(global_position, 250.0)
	elif input_dir != Vector2.ZERO and current_mode == MovementMode.WALK:
		spawned_noise.emit(global_position, 100.0)


func set_movement_mode(mode: int) -> void:
	if current_mode != mode:
		current_mode = mode
		movement_mode_changed.emit(mode)


func handle_stamina(delta: float) -> void:
	# 奔跑消耗体力
	if current_mode == MovementMode.RUN and velocity.length() > 0:
		current_stamina -= stamina_drain_rate * delta
		if current_stamina <= 0:
			current_stamina = 0
			# 体力耗尽自动切行走
			if current_mode == MovementMode.RUN:
				set_movement_mode(MovementMode.WALK)

	# 回复体力
	elif current_stamina < max_stamina:
		var regen: float = stamina_regen_rate
		if current_mode == MovementMode.CROUCH:
			regen += stamina_regen_crouch_bonus
		current_stamina = min(max_stamina, current_stamina + regen * delta)


func handle_attack(delta: float) -> void:
	# 冷却计时
	if not can_attack:
		attack_timer -= delta
		if attack_timer <= 0:
			can_attack = true
			attack_timer = 0
			is_attacking = false

	# 攻击输入
	if Input.is_action_just_pressed("melee_attack") and can_attack and current_stamina >= attack_stamina_cost:
		execute_attack()


func execute_attack() -> void:
	can_attack = false
	is_attacking = true
	attack_timer = attack_cooldown
	current_stamina -= attack_stamina_cost

	# 产生攻击噪音
	spawned_noise.emit(global_position, 150.0)

	# 计算攻击位置
	var attack_position: Vector2 = global_position + facing_direction * 20.0
	performed_attack.emit(attack_position)

	# 调用近战系统
	if melee_system:
		melee_system.execute_melee_attack(global_position, facing_direction)


func handle_interaction() -> void:
	# F 键交互 (双路检测: Input Map + 直接按键)
	var _f_down: bool = Input.is_key_pressed(KEY_F)
	var _f_just_pressed: bool = _f_down and not _f_was_down
	_f_was_down = _f_down
	var want_interact: bool = Input.is_action_just_pressed("interact") or _f_just_pressed

	if want_interact:
		var interactables: Array[Area2D] = interaction_area.get_overlapping_areas()
		for area: Area2D in interactables:
			if area.is_in_group("interactable"):
				var container: Node = area.get_parent()
				if container.has_method("interact"):
					container.interact()
					# 翻箱产生噪音
					spawned_noise.emit(global_position, 80.0)
					interacted_with.emit(container)
					return

		# 兜底: 也检测 StaticBody2D (如果 Area 检测未命中)
		var bodies: Array[Node2D] = interaction_area.get_overlapping_bodies()
		for body: Node2D in bodies:
			if body.is_in_group("interactable"):
				if body.has_method("interact"):
					body.interact()
					spawned_noise.emit(global_position, 80.0)
					interacted_with.emit(body)
					return


func take_damage(amount: int) -> void:
	if is_dead:
		return
	current_health = max(0, current_health - amount)
	print("玩家受到伤害: ", amount, " 剩余HP: ", current_health)
	player_hurt.emit(amount)

	# 屏幕血雾效果
	if HitFeedback:
		HitFeedback.apply_damage_flash(self)

	if current_health <= 0:
		die()


func die() -> void:
	is_dead = true
	velocity = Vector2.ZERO
	animated_sprite.play("death")
	# 延迟通知 GameManager
	await get_tree().create_timer(1.5).timeout
	GameManager.player_died()


func update_animation() -> void:
	if is_dead:
		return

	# 若无 SpriteFrames 资源，跳过动画播放（使用 ColorRect 视觉）
	if not animated_sprite.sprite_frames:
		return

	# 根据朝向选择方向动画
	var base: String = "walk_down"
	if abs(facing_direction.x) > abs(facing_direction.y):
		base = "walk_right" if facing_direction.x > 0 else "walk_left"
	elif facing_direction.y < 0:
		base = "walk_up"

	if is_attacking:
		animated_sprite.play(base)
		return

	if velocity.length() > 0:
		animated_sprite.play(base)
	else:
		animated_sprite.stop()
		animated_sprite.frame = 0

	# 翻转精灵朝向
	if facing_direction.x != 0:
		animated_sprite.flip_h = facing_direction.x < 0


## 从精灵表加载动画帧
func _setup_sprite_frames() -> void:
	var sheet: Texture2D = load("res://resources/sprites/spritesheet.png")
	if not sheet:
		return

	var frames: SpriteFrames = SpriteFrames.new()
	var cell: int = 32

	# 玩家四方向走路动画 (rows 0-3, 每行4帧)
	var dirs: Array[String] = ["walk_down", "walk_left", "walk_right", "walk_up"]
	for d: int in range(4):
		var anim_name: String = dirs[d]
		frames.add_animation(anim_name)
		frames.set_animation_loop(anim_name, true)
		frames.set_animation_speed(anim_name, 8.0)
		for f: int in range(4):
			var tex: AtlasTexture = AtlasTexture.new()
			tex.atlas = sheet
			tex.region = Rect2(f * cell, d * cell, cell, cell)
			frames.add_frame(anim_name, tex)

	# 僵尸动画也加进来 (供日后扩展, rows 4-6)
	var zdirs: Array[String] = ["zombie_down", "zombie_left", "zombie_right"]
	for d: int in range(3):
		var zname: String = zdirs[d]
		frames.add_animation(zname)
		frames.set_animation_loop(zname, true)
		frames.set_animation_speed(zname, 6.0)
		for f: int in range(4):
			var tex: AtlasTexture = AtlasTexture.new()
			tex.atlas = sheet
			tex.region = Rect2(f * cell, (d + 4) * cell, cell, cell)
			frames.add_frame(zname, tex)

	# 静态物品帧 (row 7)
	var items: Array[String] = ["item_crate", "item_shelf", "item_exit"]
	for i: int in range(3):
		frames.add_animation(items[i])
		frames.set_animation_loop(items[i], false)
		var tex: AtlasTexture = AtlasTexture.new()
		tex.atlas = sheet
		tex.region = Rect2(i * cell, 7 * cell, cell, cell)
		frames.add_frame(items[i], tex)

	animated_sprite.sprite_frames = frames
	animated_sprite.visible = true
	print("Sprite frames loaded: ", dirs.size(), " player + ", zdirs.size(), " zombie anims")

func heal(amount: int) -> void:
	current_health = min(max_health, current_health + amount)
