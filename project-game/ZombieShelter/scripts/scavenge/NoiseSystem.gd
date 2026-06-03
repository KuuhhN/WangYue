extends Node2D
class_name NoiseSystem

## 声音传播系统
## 接收 PlayerController.spawned_noise 信号，产生扩散声波
## 声波范围内的僵尸会被触发 ALERTED 状态

# 声波预设
const NOISE_PRESETS: Dictionary = {
	"walk": {"radius": 60.0, "color": Color(0.5, 0.8, 1.0, 0.12)},
	"run": {"radius": 150.0, "color": Color(0.8, 0.4, 0.2, 0.18)},
	"attack": {"radius": 90.0, "color": Color(1.0, 0.6, 0.0, 0.15)},
	"search": {"radius": 50.0, "color": Color(0.6, 1.0, 0.6, 0.10)},
	"gunshot": {"radius": 300.0, "color": Color(1.0, 0.2, 0.2, 0.25)}
}

@export var noise_propagation_speed: float = 400.0  # 更快扩散=视觉停留更短  # 声波扩散速度(px/s)


func _ready() -> void:
	# 连接玩家噪音信号由 MapGenerator 负责
	pass


## 玩家产生噪音
func _on_player_noise(noise_position: Vector2, intensity: float) -> void:
	create_noise_pulse(noise_position, intensity)


## 创建声波脉冲
func create_noise_pulse(origin: Vector2, intensity: float) -> void:
	# 根据强度确定声波半径
	var radius: float = intensity
	var preset_color: Color = Color(0.5, 0.8, 1.0, 0.3)

	# 匹配预设
	if intensity >= 450:
		preset_color = NOISE_PRESETS["gunshot"]["color"]
	elif intensity >= 200:
		preset_color = NOISE_PRESETS["run"]["color"]
	elif intensity >= 130:
		preset_color = NOISE_PRESETS["attack"]["color"]
	elif intensity >= 90:
		preset_color = NOISE_PRESETS["walk"]["color"]
	else:
		preset_color = NOISE_PRESETS["search"]["color"]

	# 创建视觉声波环
	spawn_noise_visual(origin, radius, preset_color)

	# 立即通知范围内的僵尸
	alert_zombies_in_radius(origin, radius)


## 视觉声波环
func spawn_noise_visual(origin: Vector2, max_radius: float, color: Color) -> void:
	var ring: ColorRect = ColorRect.new()
	ring.size = Vector2(4, 4)
	ring.color = color
	ring.position = origin - ring.size / 2.0
	add_child(ring)

	# 扩展开来并淡出
	var tween: Tween = create_tween()
	var target_size: Vector2 = Vector2(max_radius * 2, max_radius * 2)
	var target_position: Vector2 = origin - Vector2(max_radius, max_radius)
	var duration: float = max_radius / noise_propagation_speed

	tween.set_parallel(true)
	tween.tween_property(ring, "size", target_size, duration)
	tween.tween_property(ring, "position", target_position, duration)
	tween.tween_property(ring, "modulate:a", 0.0, duration)
	tween.finished.connect(ring.queue_free)


## 通知半径内的僵尸
func alert_zombies_in_radius(origin: Vector2, radius: float) -> void:
	var zombies: Array[Node] = get_tree().get_nodes_in_group("zombie")
	for zombie: Node in zombies:
		if not is_instance_valid(zombie):
			continue
		var dist: float = origin.distance_to(zombie.global_position)
		if dist <= radius and zombie.has_method("hear_noise"):
			zombie.hear_noise(origin, radius)
