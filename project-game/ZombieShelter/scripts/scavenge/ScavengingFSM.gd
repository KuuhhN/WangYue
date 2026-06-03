extends Node
class_name ScavengingFSM

## 搜打撤 状态机
## 管理扫荡过程中的三个主要阶段

# ----- 信号 -----
signal phase_changed(from_phase: int, to_phase: int)
signal withdraw_completed(loot: Dictionary)
signal scavenge_completed()

# ----- 阶段枚举 -----
enum Phase { SEARCH, STRIKE, WITHDRAW, SETTLE }

# ----- 导出属性 -----
@export var withdraw_delay_base: float = 3.0      # 基础撤离时间
@export var withdraw_delay_per_wound: float = 0.5  # 每受伤增加的撤离时间

# ----- 内部状态 -----
var current_phase: int = Phase.SEARCH
var withdraw_timer: float = 0.0
var withdraw_duration: float = 0.0
var is_withdrawing: bool = false
var collected_loot: Dictionary = {}  # 本次扫荡收集的战利品
var total_damage_taken: int = 0

# 玩家引用
var player: PlayerController = null


func _ready() -> void:
	# 找到玩家
	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	if not players.is_empty():
		player = players[0] as PlayerController
		player.player_hurt.connect(_on_player_hurt)


## 设置阶段
func set_phase(new_phase: int) -> void:
	var old_phase: int = current_phase
	current_phase = new_phase
	phase_changed.emit(old_phase, new_phase)

	match new_phase:
		Phase.SEARCH:
			on_enter_search()
		Phase.STRIKE:
			on_enter_strike()
		Phase.WITHDRAW:
			on_enter_withdraw()
		Phase.SETTLE:
			on_enter_settle()


## 进入搜索阶段
func on_enter_search() -> void:
	pass  # 玩家正常行动


## 进入战斗阶段（与僵尸交战自动触发）
func on_enter_strike() -> void:
	if player:
		# 战斗时限制奔跑
		pass


## 进入撤离阶段
func on_enter_withdraw() -> void:
	is_withdrawing = true
	# 伤势越重撤离越慢
	withdraw_duration = withdraw_delay_base + (total_damage_taken / 20.0) * withdraw_delay_per_wound
	withdraw_timer = 0.0

	if player:
		player.set_movement_mode(player.MovementMode.WALK)
		# 显示撤离进度
		print("撤离中... 需要 ", withdraw_duration, " 秒")


## 进入结算阶段
func on_enter_settle() -> void:
	# 计算战利品
	var loot_summary: Dictionary = {}
	for res_type in collected_loot:
		if loot_summary.has(res_type):
			loot_summary[res_type] += collected_loot[res_type]
		else:
			loot_summary[res_type] = collected_loot[res_type]

	withdraw_completed.emit(loot_summary)
	scavenge_completed.emit()
	# 返回避难所
	GameManager.return_to_shelter(loot_summary)


## 开始撤离（由 ExitZone 触发）
func start_withdraw() -> void:
	if current_phase != Phase.WITHDRAW:
		set_phase(Phase.WITHDRAW)


## 更新撤离进度（由 ExitZone 区域检测驱动）
func update_withdraw(delta: float) -> void:
	if not is_withdrawing:
		return

	withdraw_timer += delta

	# 玩家如果离撤离点太远则取消撤离
	if player:
		var exit_zone: Node = get_node_or_null("/root/ScavengeMap/MapGenerator/ExitZone")
		if exit_zone and player.global_position.distance_to(exit_zone.global_position) > 100:
			is_withdrawing = false
			set_phase(Phase.SEARCH)
			return

	# 撤离完成
	if withdraw_timer >= withdraw_duration:
		is_withdrawing = false
		set_phase(Phase.SETTLE)


## 添加战利品
func add_loot(resource_type: String, amount: int) -> void:
	if collected_loot.has(resource_type):
		collected_loot[resource_type] += amount
	else:
		collected_loot[resource_type] = amount


## 玩家受伤回调
func _on_player_hurt(amount: int) -> void:
	total_damage_taken += amount
	# 进入战斗状态
	if current_phase == Phase.SEARCH:
		set_phase(Phase.STRIKE)


## 通知战斗结束
func on_combat_ended() -> void:
	if current_phase == Phase.STRIKE:
		set_phase(Phase.SEARCH)
