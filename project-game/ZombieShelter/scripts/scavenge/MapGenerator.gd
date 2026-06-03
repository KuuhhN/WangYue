extends Node2D
class_name MapGenerator

## 地图生成器 - 固定超市布局
## 使用 ColorRect 和 StaticBody2D 生成无资源依赖的地图

# 地图尺寸常量
const MAP_WIDTH: int = 1200
const MAP_HEIGHT: int = 900
const TILE_SIZE: int = 32

# 房间定义：{name: {rect: Rect2, color: Color, container_count: int, zombie_count: int, loot_table: Dictionary}}
var room_defs: Dictionary = {
	"parking": {
		"rect": Rect2(0, 600, 400, 300),
		"color": Color(0.25, 0.25, 0.25),
		"containers": 1,
		"zombies": 0,
		"loot_table": {"food": 2, "scrap": 3}
	},
	"entrance": {
		"rect": Rect2(400, 600, 400, 300),
		"color": Color(0.35, 0.3, 0.25),
		"containers": 2,
		"zombies": 1,
		"loot_table": {"food": 3, "water": 2}
	},
	"checkout": {
		"rect": Rect2(800, 600, 400, 300),
		"color": Color(0.35, 0.32, 0.28),
		"containers": 2,
		"zombies": 1,
		"loot_table": {"food": 2, "scrap": 2}
	},
	"produce": {
		"rect": Rect2(0, 300, 400, 300),
		"color": Color(0.3, 0.45, 0.3),
		"containers": 2,
		"zombies": 1,
		"loot_table": {"food": 5, "water": 3}
	},
	"grocery": {
		"rect": Rect2(400, 300, 400, 300),
		"color": Color(0.35, 0.35, 0.3),
		"containers": 3,
		"zombies": 2,
		"loot_table": {"food": 4, "water": 2, "scrap": 1}
	},
	"dairy": {
		"rect": Rect2(800, 300, 400, 300),
		"color": Color(0.4, 0.4, 0.35),
		"containers": 2,
		"zombies": 1,
		"loot_table": {"food": 3, "water": 2}
	},
	"pharmacy": {
		"rect": Rect2(0, 0, 400, 300),
		"color": Color(0.3, 0.3, 0.45),
		"containers": 2,
		"zombies": 2,
		"loot_table": {"medical": 5, "scrap": 1}
	},
	"electronics": {
		"rect": Rect2(400, 0, 400, 300),
		"color": Color(0.3, 0.35, 0.4),
		"containers": 2,
		"zombies": 2,
		"loot_table": {"scrap": 5, "ammo": 2}
	},
	"warehouse": {
		"rect": Rect2(800, 0, 400, 300),
		"color": Color(0.2, 0.2, 0.22),
		"containers": 4,
		"zombies": 3,
		"loot_table": {"scrap": 6, "food": 3, "medical": 2}
	},
	"back_alley": {
		"rect": Rect2(1200, 300, 200, 600),
		"color": Color(0.2, 0.18, 0.18),
		"containers": 1,
		"zombies": 1,
		"loot_table": {"scrap": 2, "water": 1}
	}
}

# 预定义的走廊/门位置
var corridor_points: Array[Rect2] = [
	Rect2(380, 280, 40, 40),   # 连接左上-中左
	Rect2(780, 280, 40, 40),   # 连接中-右上
	Rect2(380, 580, 40, 40),   # 连接左下-中下
	Rect2(780, 580, 40, 40),   # 连接中-右下
	Rect2(1200, 280, 40, 40),  # 右到仓库
]

@onready var scavenge_hud: Node = get_node_or_null("/root/ScavengeMap/ScavengeHUD")

func _ready() -> void:
	generate_map()


func generate_map() -> void:
	# 先画背景
	draw_background()

	# 画每个房间
	for room_name in room_defs:
		var def: Dictionary = room_defs[room_name] as Dictionary
		var room_node: Node2D = create_room(def["rect"], def["color"], room_name)
		add_child(room_node)

		# 在房间内放置容器
		for i in range(def["containers"]):
			place_container(def["rect"], def["loot_table"])

		# 在房间内放置僵尸
		for i in range(def["zombies"]):
			place_zombie(def["rect"])

	# 画走廊
	for corridor in corridor_points:
		draw_corridor(corridor)

	# 画外边界墙（有碰撞）
	draw_outer_walls()

	# 放置撤离点（出口）
	place_exit_zone()

	# 放置玩家出生点
	place_player_spawn()

	# 标记房间名称
	place_room_labels()


func draw_background() -> void:
	var bg: ColorRect = ColorRect.new()
	bg.size = Vector2(MAP_WIDTH + 400, MAP_HEIGHT + 200)
	bg.position = Vector2(-100, -100)
	bg.color = Color(0.12, 0.12, 0.12)
	add_child(bg)


func create_room(rect: Rect2, color: Color, _name: String) -> Node2D:
	var room: Node2D = Node2D.new()
	room.name = "Room_" + _name

	# 地板
	var floor: ColorRect = ColorRect.new()
	floor.size = rect.size
	floor.position = rect.position
	floor.color = color
	room.add_child(floor)

	# 墙壁 - 4条边（仅视觉，无碰撞：内部墙壁允许玩家和僵尸自由穿行于房间之间）
	var wall_thickness: int = 8
	var wall_color: Color = Color(0.6, 0.55, 0.5)

	# 上墙
	var wall_top: StaticBody2D = create_wall_segment(
		rect.position.x, rect.position.y, rect.size.x, wall_thickness, wall_color, false
	)
	room.add_child(wall_top)

	# 下墙
	var wall_bottom: StaticBody2D = create_wall_segment(
		rect.position.x, rect.position.y + rect.size.y - wall_thickness,
		rect.size.x, wall_thickness, wall_color, false
	)
	room.add_child(wall_bottom)

	# 左墙
	var wall_left: StaticBody2D = create_wall_segment(
		rect.position.x, rect.position.y,
		wall_thickness, rect.size.y, wall_color, false
	)
	room.add_child(wall_left)

	# 右墙
	var wall_right: StaticBody2D = create_wall_segment(
		rect.position.x + rect.size.x - wall_thickness, rect.position.y,
		wall_thickness, rect.size.y, wall_color, false
	)
	room.add_child(wall_right)

	return room


func create_wall_segment(x: float, y: float, w: float, h: float, color: Color, add_collision: bool = true) -> StaticBody2D:
	var wall: StaticBody2D = StaticBody2D.new()

	var visual: ColorRect = ColorRect.new()
	visual.size = Vector2(w, h)
	visual.position = Vector2.ZERO
	visual.color = color
	wall.add_child(visual)

	if add_collision:
		var collision: CollisionShape2D = CollisionShape2D.new()
		var shape: RectangleShape2D = RectangleShape2D.new()
		shape.size = Vector2(w, h)
		collision.shape = shape
		collision.position = Vector2.ZERO
		wall.add_child(collision)

	wall.position = Vector2(x, y)
	wall.add_to_group("walls")
	return wall


func draw_corridor(rect: Rect2) -> void:
	var floor: ColorRect = ColorRect.new()
	floor.size = rect.size
	floor.position = rect.position
	floor.color = Color(0.3, 0.28, 0.26)
	add_child(floor)


func draw_outer_walls() -> void:
	var wall_color: Color = Color(0.5, 0.45, 0.4)
	var thickness: int = 12

	# 最外层边界（有碰撞 - 防止玩家离开地图）
	var boundary: Rect2 = Rect2(-50, -50, MAP_WIDTH + 500, MAP_WIDTH + 300)
	var wall_positions: Array = [
		[boundary.position.x, boundary.position.y, boundary.size.x, thickness],
		[boundary.position.x, boundary.position.y + boundary.size.y - thickness, boundary.size.x, thickness],
		[boundary.position.x, boundary.position.y, thickness, boundary.size.y],
		[boundary.position.x + boundary.size.x - thickness, boundary.position.y, thickness, boundary.size.y]
	]

	for wp in wall_positions:
		var wall: StaticBody2D = create_wall_segment(wp[0], wp[1], wp[2], wp[3], wall_color, true)
		add_child(wall)


func place_container(room_rect: Rect2, loot_table: Dictionary) -> void:
	var margin: float = 50.0
	var x: float = room_rect.position.x + margin + randf_range(0, room_rect.size.x - margin * 2)
	var y: float = room_rect.position.y + margin + randf_range(0, room_rect.size.y - margin * 2)

	# 使用 SearchableContainer scene
	var container_scene: PackedScene = preload("res://scenes/items/SearchableContainer.tscn")
	var container: Node = container_scene.instantiate()
	container.global_position = Vector2(x, y)
	container.set_loot_table(loot_table)
	add_child(container)


func place_zombie(room_rect: Rect2) -> void:
	var margin: float = 40.0
	var x: float = room_rect.position.x + margin + randf_range(0, room_rect.size.x - margin * 2)
	var y: float = room_rect.position.y + margin + randf_range(0, room_rect.size.y - margin * 2)

	var zombie_scene: PackedScene = preload("res://scenes/characters/Zombie.tscn")
	var zombie: Node = zombie_scene.instantiate()
	zombie.global_position = Vector2(x, y)
	add_child(zombie)


func place_exit_zone() -> void:
	# 撤离点在左下角（停车场区域出口）
	var exit_scene: PackedScene = preload("res://scenes/items/ExitZone.tscn")
	var exit_zone: Node = exit_scene.instantiate()
	exit_zone.global_position = Vector2(200, 750)  # 左下角出口位置
	add_child(exit_zone)


func place_player_spawn() -> void:
	# 出生点靠近撤离点
	var player_scene: PackedScene = preload("res://scenes/characters/PlayerCharacter.tscn")
	var player: Node = player_scene.instantiate()
	player.global_position = Vector2(200, 700)
	add_child(player)

	# 添加 Camera2D 跟随玩家
	var camera: Camera2D = Camera2D.new()
	camera.name = "PlayerCamera"
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 5.0
	camera.limit_left = -100
	camera.limit_right = MAP_WIDTH + 200
	camera.limit_top = -100
	camera.limit_bottom = MAP_HEIGHT + 200
	camera.make_current()
	player.add_child(camera)

	# 连接噪音系统
	var noise_system: Node = get_node_or_null("../NoiseSystem")
	if noise_system:
		player.spawned_noise.connect(noise_system._on_player_noise)


func place_room_labels() -> void:
	# 房间名称标签（调试用，实际通过房间颜色区分）
	var labels: Dictionary = {
		"parking": "停车场",
		"entrance": "入口",
		"checkout": "收银台",
		"produce": "蔬果区",
		"grocery": "食品区",
		"dairy": "乳制品区",
		"pharmacy": "药品区",
		"electronics": "电子区",
		"warehouse": "仓库",
		"back_alley": "后巷"
	}

	for room_name in room_defs:
		var def: Dictionary = room_defs[room_name] as Dictionary
		var center: Vector2 = def["rect"].get_center()

		var label: Label = Label.new()
		label.text = labels.get(room_name, room_name)
		label.position = center - Vector2(40, 8)
		label.add_theme_color_override("font_color", Color(1, 1, 1, 0.5))
		label.add_theme_font_size_override("font_size", 10)
		add_child(label)
