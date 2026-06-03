extends Node2D
class_name MeleeSystem

## 近战系统
## - 玩家前方扇形区域检测
## - 暴击系统（背后攻击 2x）
## - 命中反馈

@export var attack_range: float = 40.0      # 攻击范围
@export var attack_angle: float = 60.0       # 扇形角度（度）
@export var base_damage: int = 20
@export var backstab_multiplier: float = 2.0
@export var attack_cooldown: float = 0.5


## 执行近战攻击
func execute_melee_attack(origin: Vector2, direction: Vector2) -> void:
	# 获取所有僵尸
	var zombies: Array[Node] = get_tree().get_nodes_in_group("zombie")
	var closest_zombie: ZombieAI = null
	var closest_distance: float = INF

	for zombie: Node in zombies:
		if not is_instance_valid(zombie):
			continue
		if zombie.is_dead:
			continue

		# 计算与玩家的相对位置
		var to_zombie: Vector2 = zombie.global_position - origin
		var dist: float = to_zombie.length()

		# 距离检测
		if dist > attack_range:
			continue

		# 角度检测（玩家前方扇形）
		var angle: float = rad_to_deg(direction.angle_to(to_zombie.normalized()))
		if abs(angle) > attack_angle / 2.0:
			continue

		# 选取最近的僵尸
		if dist < closest_distance:
			closest_distance = dist
			closest_zombie = zombie

	if closest_zombie:
		apply_damage(closest_zombie, origin, direction)


## 应用伤害
func apply_damage(zombie: ZombieAI, origin: Vector2, direction: Vector2) -> void:
	var to_zombie: Vector2 = (zombie.global_position - origin).normalized()
	var is_backstab: bool = false

	# 检测是否是背后攻击
	# 如果僵尸的朝向与攻击方向一致，算背后攻击
	var zombie_facing: Vector2 = zombie.facing_direction
	if zombie_facing.dot(to_zombie) > 0.3:
		is_backstab = true

	var final_damage: int = base_damage
	if is_backstab:
		final_damage = int(base_damage * backstab_multiplier)

	# 应用伤害
	zombie.take_damage(final_damage, origin)

	# 命中反馈
	HitFeedback.apply_hit(get_tree().current_scene, zombie.global_position, is_backstab)
