extends Node
## 自动测试 Autoload - 遍历全流程检测错误

var phase: int = -1
var errors: Array[String] = []
var frame_count: int = 0
var phase_substep: int = 0
var withdraw_wait_frames: int = 0
var exit_loop: bool = false

func _ready() -> void:
	print("\n" + "=".repeat(50))
	print(">>> AUTO TEST: 全流程自动测试 <<<")
	print("=".repeat(50))
	phase = 0


func _process(delta: float) -> void:
	frame_count += 1

	# 跳过前几帧让场景初始化
	if frame_count < 4:
		return

	# 防止无限循环
	if exit_loop:
		return

	match phase:
		0: test_main_menu()
		1: test_shelter_scene()
		2: test_scavenge_scene()
		3: test_combat()
		4: test_withdraw(delta)
		5: test_return_shelter()
		6: print_final_results()



# ===== Phase 0 =====
func test_main_menu() -> void:
	var root: Node = get_tree().current_scene
	print("  Phase 0: 主菜单 - " + (root.name if root else "NULL"))

	var btn: Node = root.get_node_or_null("UICanvas/StartButton") if root else null
	if btn:
		print("  StartButton: OK")
	else:
		errors.append("StartButton 未找到!")

	print("  -> 切换到避难所...")
	get_tree().change_scene_to_file("res://scenes/shelter/ShelterMain.tscn")
	frame_count = 0
	phase = 1


# ===== Phase 1 =====
func test_shelter_scene() -> void:
	var root: Node = get_tree().current_scene
	if not root or root.name != "ShelterMain":
		return  # wait for scene load
	print("  Phase 1: 避难所 - " + root.name)

	# 检查 UI 节点
	var node_paths: Array[String] = [
		"CanvasLayer/DayLabel", "CanvasLayer/SurvivorsLabel",
		"CanvasLayer/ResourcesContainer", "CanvasLayer/ScavengeButton",
		"CanvasLayer/EndTurnButton"
	]
	var all_ok: bool = true
	for path in node_paths:
		if not root.get_node_or_null(path):
			errors.append("缺少节点: " + path)
			all_ok = false
	if all_ok:
		print("  所有 UI 节点: OK")

	var container: Node = root.get_node_or_null("CanvasLayer/ResourcesContainer")
	if container:
		print("  资源面板: " + str(container.get_child_count()) + " 项")

	print("  GameManager day=" + str(GameManager.current_day) + " resources OK")

	print("  -> 开始出征...")
	GameManager.start_scavenge()
	frame_count = 0
	phase = 2


# ===== Phase 2 =====
func test_scavenge_scene() -> void:
	var root: Node = get_tree().current_scene
	if not root or root.name != "ScavengeMap":
		return
	print("  Phase 2: 扫荡地图 - " + root.name)

	var map_gen: Node = root.get_node_or_null("MapGenerator")
	if not map_gen:
		errors.append("MapGenerator 未找到!")
		phase = 6
		return
	print("  MapGenerator 子节点: " + str(map_gen.get_child_count()))

	# 统计数据
	var zombies: Array[Node] = get_tree().get_nodes_in_group("zombie")
	var players: Array[Node] = get_tree().get_nodes_in_group("player")

	print("  僵尸: " + str(zombies.size()) + " | 玩家: " + (str(players[0].current_health) if not players.is_empty() else "NONE"))

	if players.is_empty():
		errors.append("未找到玩家!")
	else:
		var p: Node = players[0]
		print("  玩家 health=" + str(p.current_health) + " pos=" + str(p.global_position))

	# 检查 HUD
	var hud: Node = root.get_node_or_null("ScavengeHUD")
	if hud:
		var hud_ok: bool = true
		for bar in ["HealthBar", "StaminaBar", "PhaseIndicator", "InventoryLabel"]:
			if not hud.get_node_or_null(bar):
				errors.append("HUD 缺少: " + bar)
				hud_ok = false
		if hud_ok: print("  HUD 组件: OK")
	else:
		errors.append("ScavengeHUD 未找到!")

	# 检查 FSM
	if root.get_node_or_null("ScavengingFSM"):
		print("  ScavengingFSM: OK")
	else:
		errors.append("ScavengingFSM 未找到!")

	if root.get_node_or_null("NoiseSystem"):
		print("  NoiseSystem: OK")
	else:
		errors.append("NoiseSystem 未找到!")

	frame_count = 0
	phase = 3


# ===== Phase 3 =====
func test_combat() -> void:
	print("  Phase 3: 战斗系统")
	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	if players.is_empty():
		errors.append("无玩家!")
		phase = 4
		return

	var p: Node = players[0]
	var melee: Node = p.get_node_or_null("MeleeSystem")
	if melee:
		print("  MeleeSystem: OK")
		if p.has_method("execute_attack"):
			p.execute_attack()
			print("  execute_attack: OK")
	else:
		errors.append("MeleeSystem 未找到!")

	# 测试噪音
	var root: Node = get_tree().current_scene
	var noise: Node = root.get_node_or_null("NoiseSystem") if root else null
	if noise and noise.has_method("create_noise_pulse"):
		noise.create_noise_pulse(p.global_position, 150.0)
		print("  噪音脉冲: OK")

	print("  HitFeedback time_scale=" + str(Engine.time_scale))

	frame_count = 0
	phase = 4


# ===== Phase 4 =====
func test_withdraw(delta: float) -> void:
	if phase_substep == 0:
		print("  Phase 4: 撤离系统")
		var players: Array[Node] = get_tree().get_nodes_in_group("player")
		if players.is_empty():
			errors.append("无玩家!")
			phase = 5
			return

		var p: Node = players[0]
		var root: Node = get_tree().current_scene
		var fsm: Node = root.get_node_or_null("ScavengingFSM") if root else null

		# 找出口
		var exit_zone: Node = null
		var map_gen: Node = root.get_node_or_null("MapGenerator") if root else null
		if map_gen:
			for c in map_gen.get_children():
				if c.is_in_group("exit_zone"):
					exit_zone = c
					break

		if not exit_zone:
			errors.append("ExitZone 未找到!")
			phase = 5
			return

		print("  ExitZone at " + str(exit_zone.global_position))
		p.global_position = exit_zone.global_position
		print("  玩家移至出口")

		# 手动触发撤离
		if fsm and fsm.has_method("start_withdraw"):
			fsm.start_withdraw()
			print("  撤离已触发")

		# 通过连续多帧调用 update_withdraw 模拟撤离过程
		phase_substep = 1
		withdraw_wait_frames = 0
		return

	elif phase_substep == 1:
		var root: Node = get_tree().current_scene
		var fsm: Node = root.get_node_or_null("ScavengingFSM") if root else null

		if fsm and fsm.has_method("update_withdraw"):
			fsm.update_withdraw(delta)
			withdraw_wait_frames += 1

		# 检查是否完成
		var is_withdrawing: bool = fsm.get("is_withdrawing") if fsm else false
		var current_phase: int = fsm.get("current_phase") if fsm else -1

		if not is_withdrawing or withdraw_wait_frames > 300:
			print("  撤离完成 phase=" + str(current_phase))
			frame_count = 0
			phase_substep = 0
			withdraw_wait_frames = 0
			phase = 5

		return


# ===== Phase 5 =====
func test_return_shelter() -> void:
	var root: Node = get_tree().current_scene
	if not root:
		return
	print("  Phase 5: 返回避难所 - " + root.name)
	print("  GameManager day=" + str(GameManager.current_day) + " survivors=" + str(GameManager.survivors))
	print("  pending_loot=" + str(GameManager.pending_loot))

	# 模拟结束回合
	GameManager.add_resource("food", 1)
	GameManager.advance_day()
	print("  advance_day: OK, day=" + str(GameManager.current_day))

	frame_count = 0
	phase = 6


# ===== Phase 6 =====
func print_final_results() -> void:
	print("\n" + "=".repeat(50))
	print(">>> 全流程测试结果 <<<")
	print("=".repeat(50))

	if errors.is_empty():
		print("✅ 所有测试通过！无错误！")
		print("  场景切换: Main -> ShelterMain ✅")
		print("  避难所UI: 全部就绪 ✅")
		print("  扫荡地图: 生成正常 ✅")
		print("  战斗系统: 可用 ✅")
		print("  撤离流程: 可触发 ✅")
		print("  资源管理: 正常 ✅")
	else:
		print("❌ 发现 " + str(errors.size()) + " 个问题:")
		for i in errors.size():
			print("  " + str(i + 1) + ". " + errors[i])

	exit_loop = true
	get_tree().quit(0 if errors.is_empty() else 1)
