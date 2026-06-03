extends StaticBody2D
class_name SearchableContainer

## 可搜索容器 - 翻箱获得物资

signal container_searched(loot: Dictionary)

@export var loot_table: Dictionary = {"food": 2, "scrap": 1}
@export var loot_count_range: Vector2 = Vector2(1, 3)  # 最少/最多掉落物品种类数
@export var is_searched: bool = false

@onready var visual: ColorRect = $Visual
@onready var searched_indicator: ColorRect = $Visual/SearchedIndicator
@onready var interaction_area: Area2D = $InteractionArea

func _ready() -> void:
	add_to_group("interactable")
	interaction_area.add_to_group("interactable")


func set_loot_table(table: Dictionary) -> void:
	loot_table = table


func interact() -> void:
	if is_searched:
		return

	is_searched = true
	visual.color = Color(0.4, 0.35, 0.25, 0.7)
	searched_indicator.visible = true

	# 生成战利品
	var loot: Dictionary = generate_loot()
	emit_signal("container_searched", loot)

	# 通知 ScavengingFSM
	var scavenge_fsm: Node = get_node_or_null("/root/ScavengeMap/ScavengingFSM")
	if scavenge_fsm:
		for res_type in loot:
			scavenge_fsm.add_loot(res_type, loot[res_type])

	# 更新 HUD
	var hud: Node = get_node_or_null("/root/ScavengeMap/ScavengeHUD")
	if hud:
		hud.update_inventory(scavenge_fsm.collected_loot if scavenge_fsm else {})

	print("搜索容器，获得: ", loot)


## 根据战利品表生成实际战利品
func generate_loot() -> Dictionary:
	var result: Dictionary = {}
	var num_items: int = int(randf_range(loot_count_range.x, loot_count_range.y))

	# 从战利品表中随机选取 num_items 种
	var types: Array = loot_table.keys()
	types.shuffle()

	for i in range(min(num_items, types.size())):
		var res_type: String = types[i] as String
		var base_amount: int = loot_table[res_type] as int
		# 随机波动 ±50%
		var amount: int = max(1, int(base_amount * randf_range(0.5, 1.5)))
		result[res_type] = amount

	return result
