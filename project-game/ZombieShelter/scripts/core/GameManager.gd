extends Node
## 全局游戏状态管理 (Autoload 单例)
##
## 管理资源、幸存者、天数、出征/返回避难所逻辑

signal day_changed(new_day: int)
signal resource_changed(resource_type: String, new_amount: int)
signal game_over(reason: String)
signal scavenge_started()
signal returned_to_shelter(loot: Dictionary)

# 资源类型常量
const RESOURCE_FOOD: String = "food"
const RESOURCE_WATER: String = "water"
const RESOURCE_MEDICAL: String = "medical"
const RESOURCE_AMMO: String = "ammo"
const RESOURCE_SCRAP: String = "scrap"

# 当前游戏状态
var current_day: int = 1
var current_phase: String = "shelter"  # shelter, scavenge, settlement

# 资源存储
var resources: Dictionary = {
	RESOURCE_FOOD: 20,
	RESOURCE_WATER: 20,
	RESOURCE_MEDICAL: 5,
	RESOURCE_AMMO: 0,
	RESOURCE_SCRAP: 10
}

# 幸存者系统
var survivors: int = 3          # 总幸存者数
var active_team_members: int = 1  # 当前出征人数
var survivor_alive: bool = true   # 出征角色是否存活

# 每日消耗
var daily_food_consumption: int = 2
var daily_water_consumption: int = 2

# 扫荡带回的战利品（临时存储）
var pending_loot: Dictionary = {}

func _ready() -> void:
	print("GameManager 初始化完成 - Day ", current_day)


# ----- 资源管理 -----

func add_resource(type: String, amount: int) -> void:
	if not resources.has(type):
		push_warning("未知资源类型: ", type)
		return
	resources[type] += amount
	resource_changed.emit(type, resources[type])


func remove_resource(type: String, amount: int) -> bool:
	if not resources.has(type):
		push_warning("未知资源类型: ", type)
		return false
	if resources[type] < amount:
		return false
	resources[type] -= amount
	resource_changed.emit(type, resources[type])
	return true


func get_resource(type: String) -> int:
	return resources.get(type, 0)


func has_resources(type: String, amount: int) -> bool:
	return resources.get(type, 0) >= amount


# ----- 天数管理 -----

func advance_day() -> void:
	# 消耗每日资源
	if not remove_resource(RESOURCE_FOOD, daily_food_consumption):
		game_over.emit("食物耗尽 - 避难所陷落")
		return
	if not remove_resource(RESOURCE_WATER, daily_water_consumption):
		game_over.emit("水源耗尽 - 避难所陷落")
		return

	current_day += 1
	day_changed.emit(current_day)
	print("Day ", current_day, " - 资源消耗完毕")


func has_sufficient_for_days(days: int) -> bool:
	var needed_food: int = daily_food_consumption * days
	var needed_water: int = daily_water_consumption * days
	return resources[RESOURCE_FOOD] >= needed_food and resources[RESOURCE_WATER] >= needed_water


# ----- 场景切换 -----

func start_scavenge() -> void:
	current_phase = "scavenge"
	survivor_alive = true
	pending_loot = {}
	scavenge_started.emit()
	get_tree().change_scene_to_file("res://scenes/scavenge/ScavengeMap.tscn")


func return_to_shelter(loot_items: Dictionary) -> void:
	pending_loot = loot_items.duplicate()

	# 添加战利品到资源
	for res_type in loot_items:
		var amount: int = loot_items[res_type] as int
		if amount > 0:
			add_resource(res_type, amount)

	# 重置状态
	current_phase = "shelter"
	returned_to_shelter.emit(pending_loot)
	get_tree().change_scene_to_file("res://scenes/shelter/ShelterMain.tscn")


func player_died() -> void:
	survivor_alive = false
	survivors -= 1
	if survivors <= 0:
		game_over.emit("所有幸存者阵亡 - 人类灭绝")

	current_phase = "shelter"
	returned_to_shelter.emit({})
	get_tree().change_scene_to_file("res://scenes/shelter/ShelterMain.tscn")
