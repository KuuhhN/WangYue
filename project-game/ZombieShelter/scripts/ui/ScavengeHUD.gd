extends CanvasLayer
class_name ScavengeHUD

## 扫荡 HUD
## 显示血量、体力、搜打撤状态、背包、操作提示

@onready var health_bar: ProgressBar = $HealthBar
@onready var stamina_bar: ProgressBar = $StaminaBar
@onready var phase_indicator: Label = $PhaseIndicator
@onready var inventory_label: Label = $InventoryLabel
@onready var controls_hint: Label = $ControlsHint
@onready var interact_hint: Label = $InteractHint
@onready var withdraw_progress: ProgressBar = $WithdrawProgress
@onready var withdraw_label: Label = $WithdrawLabel

var player: PlayerController = null
var scavenge_fsm: ScavengingFSM = null

func _ready() -> void:
	# 延迟帧初始化确保场景加载完毕
	await get_tree().process_frame

	var players := get_tree().get_nodes_in_group("player")
	if not players.is_empty():
		player = players[0] as PlayerController
		player.player_hurt.connect(update_health_bar)
		player.movement_mode_changed.connect(_on_mode_changed)

	scavenge_fsm = get_node_or_null("/root/ScavengeMap/ScavengingFSM")
	if scavenge_fsm:
		scavenge_fsm.phase_changed.connect(_on_phase_changed)

	interact_hint.visible = false
	withdraw_progress.visible = false
	withdraw_label.visible = false


func _process(delta: float) -> void:
	if not player:
		return

	update_health_bar(player.current_health)
	update_stamina_bar(player.current_stamina)
	update_interact_hint()

	# 更新撤离进度条
	if scavenge_fsm and scavenge_fsm.is_withdrawing:
		update_withdraw_progress(scavenge_fsm.withdraw_timer, scavenge_fsm.withdraw_duration)
		withdraw_progress.visible = true
		withdraw_label.visible = true


func update_health_bar(value: int) -> void:
	health_bar.max_value = player.max_health
	health_bar.value = value
	# 颜色变化：绿 > 黄 > 红
	if value > player.max_health * 0.5:
		health_bar.modulate = Color(0.3, 0.9, 0.3)
	elif value > player.max_health * 0.25:
		health_bar.modulate = Color(0.9, 0.8, 0.2)
	else:
		health_bar.modulate = Color(0.9, 0.2, 0.2)


func update_stamina_bar(value: float) -> void:
	stamina_bar.max_value = player.max_stamina
	stamina_bar.value = value
	# 体力值颜色
	if value > player.max_stamina * 0.5:
		stamina_bar.modulate = Color(0.2, 0.7, 0.9)
	elif value > player.max_stamina * 0.25:
		stamina_bar.modulate = Color(0.9, 0.7, 0.2)
	else:
		stamina_bar.modulate = Color(0.9, 0.3, 0.2)


func update_interact_hint() -> void:
	if not player:
		return

	var found_interactable: bool = false
	var area: Node = player.get_node_or_null("InteractionArea")
	if area:
		var overlapping: Array[Area2D] = area.get_overlapping_areas()
		for a in overlapping:
			if a.is_in_group("interactable") and a.get_parent().has_method("interact"):
				found_interactable = true
				break

	interact_hint.visible = found_interactable


func _on_mode_changed(mode: int) -> void:
	match mode:
		PlayerController.MovementMode.CROUCH:
			controls_hint.text = "移动: WASD | 蹲伏"
		PlayerController.MovementMode.WALK:
			controls_hint.text = "移动: WASD | 奔跑: Shift | 蹲伏: Ctrl"
		PlayerController.MovementMode.RUN:
			controls_hint.text = "移动: WASD | 奔跑中"


func _on_phase_changed(from: int, to: int) -> void:
	match to:
		ScavengingFSM.Phase.SEARCH:
			phase_indicator.text = "🔍 搜索"
			phase_indicator.modulate = Color(0.3, 0.8, 0.3)
			withdraw_progress.visible = false
			withdraw_label.visible = false
		ScavengingFSM.Phase.STRIKE:
			phase_indicator.text = "⚔️ 战斗"
			phase_indicator.modulate = Color(0.9, 0.2, 0.2)
		ScavengingFSM.Phase.WITHDRAW:
			phase_indicator.text = "🏃 撤离"
			phase_indicator.modulate = Color(0.2, 0.6, 0.9)
			withdraw_progress.visible = true
			withdraw_label.visible = true
		ScavengingFSM.Phase.SETTLE:
			phase_indicator.text = "✅ 结算"
			phase_indicator.modulate = Color(0.8, 0.8, 0.2)


func update_withdraw_progress(current: float, total: float) -> void:
	withdraw_progress.max_value = total
	withdraw_progress.value = current
	withdraw_label.text = "撤离中... %d%%" % int((current / total) * 100)


func update_inventory(loot: Dictionary) -> void:
	var text: String = "背包: "
	var items: Array[String] = []
	for res_type in loot:
		var name: String = ResourceManager.DISPLAY_NAMES.get(res_type, res_type) as String
		items.append("%s+%d" % [name, loot[res_type]])

	if items.is_empty():
		text += "空"
	else:
		text += ", ".join(items)

	inventory_label.text = text
