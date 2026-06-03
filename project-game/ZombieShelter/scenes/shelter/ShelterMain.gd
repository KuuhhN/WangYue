extends Node2D
## 避难所场景脚本

# UI 节点引用
@onready var day_label: Label = $CanvasLayer/DayLabel
@onready var survivors_label: Label = $CanvasLayer/SurvivorsLabel
@onready var resources_container: VBoxContainer = $CanvasLayer/ResourcesContainer
@onready var event_label: Label = $CanvasLayer/EventLabel
@onready var scavenge_button: Button = $CanvasLayer/ScavengeButton
@onready var end_turn_button: Button = $CanvasLayer/EndTurnButton
@onready var result_label: Label = $CanvasLayer/ResultLabel

# 随机事件池
var events_pool: Array[Dictionary] = [
	{"text": "巡逻队发现了一个废弃仓库，获得了一些物资。", "effect": {"food": 3, "scrap": 2}},
	{"text": "一名幸存者感染了病毒，药品消耗增加。", "effect": {"medical": -2}},
	{"text": "雨水收集装置修复完成，水源供给改善。", "effect": {"water": 4}},
	{"text": "地鼠闯入储藏室，损失了一些食物。", "effect": {"food": -2}},
	{"text": "隔壁避难所传来求救信号，是否回应尚未决定。", "effect": {}},
	{"text": "废料回收成功，金属零件增加了。", "effect": {"scrap": 3}},
	{"text": "天气晴朗，适合外出行动。", "effect": {}},
	{"text": "无线电收到其他幸存者的消息，士气提升。", "effect": {"food": 1}},
]


func _ready() -> void:
	update_ui()

	# 连接到 GameManager 信号
	GameManager.resource_changed.connect(_on_resource_changed)
	GameManager.game_over.connect(_on_game_over)
	GameManager.returned_to_shelter.connect(_on_returned_to_shelter)

	# 如果有带回的战利品，显示结算
	if not GameManager.pending_loot.is_empty():
		show_loot_result(GameManager.pending_loot)

	event_label.text = "新的一天开始。准备行动。"
	result_label.visible = false


func update_ui() -> void:
	day_label.text = "第 %d 天" % GameManager.current_day
	survivors_label.text = "幸存者: %d" % GameManager.survivors

	# 更新资源面板
	for child in resources_container.get_children():
		child.queue_free()

	for res_type in ResourceManager.ALL_TYPES:
		var amount: int = ResourceManager.get_amount(res_type)
		var name: String = ResourceManager.DISPLAY_NAMES.get(res_type, res_type) as String
		var color: Color = ResourceManager.COLORS.get(res_type, Color.WHITE) as Color

		var hbox := HBoxContainer.new()
		var icon := ColorRect.new()
		icon.size = Vector2(16, 16)
		icon.color = color
		var label := Label.new()
		label.text = "%s: %d" % [name, amount]
		label.add_theme_color_override("font_color", Color.WHITE)

		hbox.add_child(icon)
		hbox.add_child(label)
		resources_container.add_child(hbox)


func _on_resource_changed(type: String, amount: int) -> void:
	update_ui()


func _on_scavenge_pressed() -> void:
	# 出征
	GameManager.start_scavenge()


func _on_end_turn_pressed() -> void:
	# 消耗一天资源 + 触发随机事件
	var event: Dictionary = events_pool.pick_random()
	event_label.text = event.text

	# 应用事件效果
	for res_type in event.get("effect", {}):
		var amount: int = event["effect"][res_type] as int
		if amount > 0:
			ResourceManager.add(res_type, amount)
		else:
			ResourceManager.remove(res_type, -amount)

	GameManager.advance_day()


func show_loot_result(loot: Dictionary) -> void:
	result_label.visible = true
	var text := "🔙 返回避难所\n\n—— 战利品 ——\n"
	for res_type in loot:
		var name: String = ResourceManager.DISPLAY_NAMES.get(res_type, res_type) as String
		text += "%s: +%d\n" % [name, loot[res_type]]

	if loot.is_empty():
		text += "此次扫荡一无所获。"

	result_label.text = text


func _on_returned_to_shelter(loot: Dictionary) -> void:
	show_loot_result(loot)
	update_ui()


func _on_game_over(reason: String) -> void:
	event_label.text = "游戏结束: " + reason
	scavenge_button.disabled = true
	end_turn_button.disabled = true
