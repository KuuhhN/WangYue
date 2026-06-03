extends Area2D
class_name ExitZone

## 撤离点 - 到达此区域触发 WITHDRAW 阶段

@export var withdraw_trigger_distance: float = 50.0

@onready var visual: ColorRect = $Visual
@onready var label: Label = $Label
@onready var arrow: ColorRect = $Arrow

var player_in_zone: bool = false
var scavenge_fsm: ScavengingFSM = null


func _ready() -> void:
	add_to_group("exit_zone")
	scavenge_fsm = get_node_or_null("/root/ScavengeMap/ScavengingFSM")

	# 浮动动画
	var tween: Tween = create_tween()
	tween.set_loops()
	tween.tween_property(label, "position", Vector2(-24, -20), 1.0)
	tween.tween_property(label, "position", Vector2(-24, -30), 1.0)


func _process(delta: float) -> void:
	if player_in_zone and scavenge_fsm:
		scavenge_fsm.start_withdraw()
		scavenge_fsm.update_withdraw(delta)


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_zone = true
		print("进入撤离点！")


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_zone = false
		print("离开撤离点")
