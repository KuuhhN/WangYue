extends Node
## 自动测试脚本 - 遍历所有场景检测错误

var test_phase: int = 0
var timer: float = 0.0
var errors_found: Array[String] = []

func _ready() -> void:
	print("=".repeat(50))
	print(">>> 自动化测试开始 <<<")
	print("=".repeat(50))

	# Phase 0: 主菜单已经加载，切换到避难所
	test_phase = 0
	call_deferred("run_phase_0")


func run_phase_0() -> void:
	print("\n>>> Phase 0: 进入避难所场景")
	var err := get_tree().change_scene_to_file("res://scenes/shelter/ShelterMain.tscn")
	if err != OK:
		errors_found.append("Phase 0: change_scene_to_file 返回错误 " + str(err))

	# 等待场景加载完成
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame

	print("Phase 0 完成 - ShelterMain 已加载")
	call_deferred("run_phase_1")


func run_phase_1() -> void:
	print("\n>>> Phase 1: 检查避难所场景节点")

	var root := get_tree().current_scene
	if not root:
		errors_found.append("Phase 1: current_scene 为空!")
		call_deferred("print_results")
		return

	print("  当前场景: ", root.name if root else "NULL")

	var canvas := root.get_node_or_null("CanvasLayer")
	if not canvas:
		errors_found.append("Phase 1: CanvasLayer 未找到!")

	var btn := root.get_node_or_null("CanvasLayer/ScavengeButton")
	if not btn:
		errors_found.append("Phase 1: ScavengeButton 未找到!")
	else:
		print("  ScavengeButton 就绪: disabled=", btn.disabled)

	var end_btn := root.get_node_or_null("CanvasLayer/EndTurnButton")
	if not end_btn:
		errors_found.append("Phase 1: EndTurnButton 未找到!")

	var day_label := root.get_node_or_null("CanvasLayer/DayLabel")
	if not day_label:
		errors_found.append("Phase 1: DayLabel 未找到!")
	else:
		print("  DayLabel: ", day_label.text)

	var res_container := root.get_node_or_null("CanvasLayer/ResourcesContainer")
	if not res_container:
		errors_found.append("Phase 1: ResourcesContainer 未找到!")
	else:
		print("  ResourcesContainer 子节点数: ", res_container.get_child_count())

	# 检查 GameManager
	print("  GameManager 天数: ", GameManager.current_day)
	print("  GameManager 资源: ", GameManager.resources)

	print("Phase 1 完成")
	call_deferred("run_phase_2")


func run_phase_2() -> void:
	print("\n>>> Phase 2: 模拟点击出征按钮 -> 进入扫荡地图")

	# 直接调用 GameManager 的 start_scavenge
	GameManager.start_scavenge()

	# 等待场景切换
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame

	print("Phase 2 完成")
	call_deferred("run_phase_3")


func run_phase_3() -> void:
	print("\n>>> Phase 3: 检查扫荡地图场景")

	var root := get_tree().current_scene
	if not root:
		errors_found.append("Phase 3: current_scene 为空!")
		call_deferred("print_results")
		return

	print("  当前场景: ", root.name if root else "NULL")

	# 检查子节点
	for child in root.get_children():
		print("  子节点: ", child.name, " (", child.get_class(), ")")

	# 检查 MapGenerator
	var map_gen := root.get_node_or_null("MapGenerator")
	if not map_gen:
		errors_found.append("Phase 3: MapGenerator 未找到!")
	else:
		print("  MapGenerator 子节点数: ", map_gen.get_child_count())

	# 检查玩家
	var players := get_tree().get_nodes_in_group("player")
	if players.is_empty():
		errors_found.append("Phase 3: 未找到玩家!")
	else:
		var player := players[0]
		print("  玩家: ", player.name, " 位置: ", player.global_position)
		print("  玩家 mode: ", player.current_mode if player.has_method("set_movement_mode") else "N/A")
		print("  玩家 health: ", player.current_health, "/", player.max_health)

	# 检查僵尸
	var zombies := get_tree().get_nodes_in_group("zombie")
	print("  僵尸数量: ", zombies.size())

	# 检查 ScavengingFSM
	var fsm := root.get_node_or_null("ScavengingFSM")
	if not fsm:
		errors_found.append("Phase 3: ScavengingFSM 未找到!")
	else:
		print("  FSM 当前阶段: ", fsm.current_phase)

	# 检查 NoiseSystem
	var noise := root.get_node_or_null("NoiseSystem")
	if not noise:
		errors_found.append("Phase 3: NoiseSystem 未找到!")

	# 检查 ScavengeHUD
	var hud := root.get_node_or_null("ScavengeHUD")
	if not hud:
		errors_found.append("Phase 3: ScavengeHUD 未找到!")
	else:
		var health_bar := hud.get_node_or_null("HealthBar")
		if not health_bar:
			errors_found.append("Phase 3: HealthBar 未找到!")
		var stamina_bar := hud.get_node_or_null("StaminaBar")
		if not stamina_bar:
			errors_found.append("Phase 3: StaminaBar 未找到!")

	# 检查可交互容器
	var containers := get_tree().get_nodes_in_group("interactable")
	print("  可交互容器数: ", containers.size())

	print("Phase 3 完成")
	call_deferred("run_phase_4")


func run_phase_4() -> void:
	print("\n>>> Phase 4: 模拟战斗 - 玩家攻击")

	var players := get_tree().get_nodes_in_group("player")
	if players.is_empty():
		errors_found.append("Phase 4: 无玩家可攻击!")
		call_deferred("print_results")
		return

	var player := players[0]

	# 模拟执行攻击
	if player.has_method("execute_attack"):
		player.execute_attack()
		print("  执行攻击完成")
	else:
		errors_found.append("Phase 4: 玩家没有 execute_attack 方法!")

	await get_tree().process_frame

	# 检查 MeleeSystem
	var melee := player.get_node_or_null("MeleeSystem")
	if not melee:
		errors_found.append("Phase 4: MeleeSystem 未找到!")
		print("  注意: 周围若无僵尸，攻击不会有命中效果（正常）")

	print("Phase 4 完成")
	call_deferred("run_phase_5")


func run_phase_5() -> void:
	print("\n>>> Phase 5: 模拟撤离 - 玩家到达出口")

	var players := get_tree().get_nodes_in_group("player")
	if players.is_empty():
		errors_found.append("Phase 5: 无玩家!")
		call_deferred("print_results")
		return

	var player := players[0]
	var root := get_tree().current_scene

	# 找到 ExitZone
	var exit_zone: Node = null
	var map_gen := root.get_node_or_null("MapGenerator")
	if map_gen:
		for child in map_gen.get_children():
			if child.is_in_group("exit_zone"):
				exit_zone = child
				break

	if not exit_zone:
		errors_found.append("Phase 5: ExitZone 未找到!")
	else:
		print("  ExitZone 位置: ", exit_zone.global_position)

		# 移动玩家到出口
		player.global_position = exit_zone.global_position
		print("  玩家移到出口: ", player.global_position)

	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame

	# 检查 FSM 是否进入撤离
	var fsm := root.get_node_or_null("ScavengingFSM")
	if fsm:
		print("  FSM 阶段: ", fsm.current_phase, " (期望: WITHDRAW)")
		if fsm.current_phase != ScavengingFSM.Phase.WITHDRAW:
			errors_found.append("Phase 5: FSM 未进入 WITHDRAW 阶段! 当前: " + str(fsm.current_phase))

	print("Phase 5 完成")

	# 模拟撤离等待
	print("\n  等待撤离计时完成...")
	for i in range(60):  # 等待最多 60 帧
		if fsm and fsm.current_phase == ScavengingFSM.Phase.SETTLE:
			print("  撤离完成，进入 SETTLE 阶段")
			break
		if fsm and fsm.is_withdrawing:
			# 模拟 ExitZone._process 调用
			if fsm.has_method("update_withdraw"):
				fsm.update_withdraw(1.0 / 60.0)
		await get_tree().process_frame

	call_deferred("run_phase_6")


func run_phase_6() -> void:
	print("\n>>> Phase 6: 检查返回避难所")

	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame

	var root := get_tree().current_scene
	if root:
		print("  当前场景: ", root.name)

	# 检查 GameManager 状态
	print("  GameManager phase: ", GameManager.current_phase)
	print("  GameManager 资源: ", GameManager.resources)
	print("  GameManager pending_loot: ", GameManager.pending_loot)

	print("Phase 6 完成")
	call_deferred("print_results")


func print_results() -> void:
	print("\n" + "=".repeat(50))
	print(">>> 测试结果汇总 <<<")
	print("=".repeat(50))

	if errors_found.is_empty():
		print("✅ 所有测试通过! 未发现错误!")
	else:
		print("❌ 发现 ", errors_found.size(), " 个错误:")
		for i in errors_found.size():
			print("  ", i + 1, ". ", errors_found[i])

	print("\n测试完成，退出...")
	get_tree().quit(0 if errors_found.is_empty() else 1)
