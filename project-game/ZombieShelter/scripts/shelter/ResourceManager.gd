extends Node
class_name ResourceManager

## 资源管理系统
## 管理 5 种核心生存资源

# 资源类型常量
const FOOD: String = "food"
const WATER: String = "water"
const MEDICAL: String = "medical"
const AMMO: String = "ammo"
const SCRAP: String = "scrap"

# 所有资源类型列表
const ALL_TYPES: Array[String] = [FOOD, WATER, MEDICAL, AMMO, SCRAP]

# 资源显示名称
const DISPLAY_NAMES: Dictionary = {
	FOOD: "食物",
	WATER: "水",
	MEDICAL: "药品",
	AMMO: "弹药",
	SCRAP: "废料"
}

# 资源颜色
const COLORS: Dictionary = {
	FOOD: Color(0.8, 0.6, 0.2),
	WATER: Color(0.2, 0.6, 1.0),
	MEDICAL: Color(0.2, 0.9, 0.4),
	AMMO: Color(0.9, 0.6, 0.2),
	SCRAP: Color(0.6, 0.6, 0.6)
}


## 添加资源
static func add(type: String, amount: int) -> void:
	GameManager.add_resource(type, amount)


## 移除资源，返回是否成功
static func remove(type: String, amount: int) -> bool:
	return GameManager.remove_resource(type, amount)


## 获取资源数量
static func get_amount(type: String) -> int:
	return GameManager.get_resource(type)


## 检查资源是否充足
static func has(type: String, amount: int) -> bool:
	return GameManager.has_resources(type, amount)


## 每日消耗
static func daily_consume(survivor_count: int) -> bool:
	var food_needed: int = 2 * survivor_count
	var water_needed: int = 2 * survivor_count

	if not remove(FOOD, food_needed):
		return false
	if not remove(WATER, water_needed):
		return false
	return true


## 检查是否能支撑指定天数
static func has_sufficient_for_days(days: int) -> bool:
	return GameManager.has_sufficient_for_days(days)


## 获取所有资源的摘要文本
static func get_summary() -> String:
	var lines: Array[String] = []
	for res_type in ALL_TYPES:
		var name: String = DISPLAY_NAMES.get(res_type, res_type) as String
		var amount: int = get_amount(res_type)
		lines.append("%s: %d" % [name, amount])
	return "\n".join(lines)
