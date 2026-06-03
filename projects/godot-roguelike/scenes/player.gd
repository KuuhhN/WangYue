extends CharacterBody2D
## Player base class. All character types inherit from this.

class_name PlayerBase

@export var max_hp: int = 80
@export var speed: int = 280
@export var attack_damage: int = 12
@export var attack_cooldown: float = 0.6
@export var skill_cooldown: float = 8.0

var current_hp: int = 80
var is_attacking: bool = false
var is_skill_active: bool = false
var can_attack: bool = true
var can_skill: bool = true
var invulnerable: bool = false
var invuln_timer: float = 0.0
var defense_bonus: int = 0
var speed_bonus: int = 0

@onready var sprite: Sprite2D = $Sprite2D
@onready var attack_timer: Timer = $AttackTimer
@onready var skill_timer: Timer = $SkillTimer
@onready var invuln_timer_node: Timer = $InvulnTimer
@onready var hitbox: Area2D = $Hitbox


func _ready() -> void:
	current_hp = max_hp
	attack_timer.wait_time = attack_cooldown
	skill_timer.wait_time = skill_cooldown
	invuln_timer_node.wait_time = 0.5
	_hook_signals()


func _hook_signals() -> void:
	EventBus.game_over.connect(_on_game_over)


func _physics_process(_delta: float) -> void:
	if GameManager.is_game_over:
		return
	_handle_movement()


func _handle_movement() -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var current_speed: float = speed + speed_bonus
	velocity = input_dir * current_speed
	move_and_slide()


func _input(event: InputEvent) -> void:
	if GameManager.is_game_over:
		return
	if event.is_action_pressed("left_click") or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
		if can_attack:
			attack()
	if event.is_action_pressed("right_click") or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed):
		if can_skill:
			use_skill()


## Override in subclasses
func attack() -> void:
	pass


## Override in subclasses
func use_skill() -> void:
	pass


func take_damage(amount: int) -> void:
	if invulnerable or GameManager.is_game_over:
		return
	var final_damage: int = maxi(1, amount - defense_bonus)
	current_hp = maxi(0, current_hp - final_damage)
	invulnerable = true
	invuln_timer_node.start()
	_modulate_flash(Color.RED)
	EventBus.player_damaged.emit(current_hp, max_hp)
	EventBus.damage_dealt.emit(final_damage, global_position, Color.RED)
	if current_hp <= 0:
		die()


func heal(amount: int) -> void:
	current_hp = mini(max_hp, current_hp + amount)
	EventBus.player_healed.emit(current_hp, max_hp)


func die() -> void:
	GameManager.is_game_over = true
	EventBus.player_died.emit()
	EventBus.game_over.emit()


func _on_game_over() -> void:
	queue_free()


func _modulate_flash(color: Color) -> void:
	sprite.modulate = color
	await get_tree().create_timer(0.1).timeout
	if is_instance_valid(sprite):
		sprite.modulate = Color.WHITE


func _on_invuln_timeout() -> void:
	invulnerable = false


func _on_attack_timer_timeout() -> void:
	can_attack = true


func _on_skill_timer_timeout() -> void:
	can_skill = true


func start_attack_cooldown() -> void:
	can_attack = false
	attack_timer.start()


func start_skill_cooldown() -> void:
	can_skill = false
	skill_timer.start()


func get_mouse_direction() -> Vector2:
	return (get_global_mouse_position() - global_position).normalized()
