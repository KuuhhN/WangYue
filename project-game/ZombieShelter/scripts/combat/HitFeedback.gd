extends Node
class_name HitFeedback

## 命中反馈系统
## - 屏幕震动
## - 命中闪光
## - 卡肉感（快门效果）
## - 粒子效果

static var camera_shake_intensity: float = 4.0
static var camera_shake_duration: float = 0.15
static var hit_stop_duration: float = 0.03  # 卡肉感时间(秒)

## 应用命中反馈
static func apply_hit(world: Node2D, hit_position: Vector2, is_critical: bool = false) -> void:
	# 屏幕震动
	shake_camera(world, camera_shake_intensity * (2.0 if is_critical else 1.0))

	# 卡肉感（短时间暂停）
	hit_stop()

	# 命中粒子效果
	spawn_hit_particles(world, hit_position, is_critical)


## 屏幕震动 - 直接调制 Camera2D offset
static func shake_camera(world: Node2D, intensity: float) -> void:
	var camera: Camera2D = get_active_camera(world)
	if not camera:
		return

	var original_offset: Vector2 = camera.offset
	var duration: float = camera_shake_duration

	# 使用 Tween 直接调制 offset
	var tween: Tween = world.create_tween()
	tween.set_parallel(false)

	# 抖动循环
	for i in range(3):
		var shake_x: float = randf_range(-intensity, intensity)
		var shake_y: float = randf_range(-intensity, intensity)
		tween.tween_property(camera, "offset", Vector2(shake_x, shake_y), duration / 6.0)

	tween.tween_property(camera, "offset", original_offset, duration / 6.0)


## 卡肉感 - 短时间暂停 + 白色闪烁
static func hit_stop() -> void:
	if hit_stop_duration <= 0:
		return

	Engine.time_scale = 0.05  # 极慢动作代替完全暂停
	var tree: MainLoop = Engine.get_main_loop()
	if tree is SceneTree:
		# Godot 4: 使用 create_timer 的 ignore_time_scale 参数
		await tree.create_timer(hit_stop_duration, true, false, true).timeout
		Engine.time_scale = 1.0


## 命中粒子效果
static func spawn_hit_particles(world: Node2D, position: Vector2, is_critical: bool) -> void:
	var particle: ColorRect = ColorRect.new()
	particle.size = Vector2(6, 6) if not is_critical else Vector2(10, 10)
	particle.color = Color(1, 0.3, 0.1, 0.9) if not is_critical else Color(1, 0.9, 0.1, 1.0)
	particle.position = position - particle.size / 2.0
	world.add_child(particle)

	# 扩散动画
	var tween: Tween = world.create_tween()
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(particle, "scale", Vector2(3, 3), 0.15)
	tween.parallel().tween_property(particle, "modulate", Color(1, 1, 1, 0), 0.15)
	tween.finished.connect(particle.queue_free)


## 受击血色闪烁
static func apply_damage_flash(target: CanvasItem) -> void:
	if not target:
		return
	var original_modulate: Color = target.modulate
	target.modulate = Color(1, 0.2, 0.2, 0.6)
	await target.get_tree().create_timer(0.1).timeout
	target.modulate = original_modulate


## 获取活动摄像机
static func get_active_camera(world: Node2D) -> Camera2D:
	var players: Array[Node] = world.get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return null
	var player: Node2D = players[0] as Node2D
	var cameras: Array[Node] = player.find_children("", "Camera2D")
	if not cameras.is_empty():
		return cameras[0] as Camera2D
	return null
