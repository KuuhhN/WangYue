extends Node2D
## RoomManager: Generates dungeon rooms with TileMap, enemies, chests, gates.

const TILE_SIZE: int = 16
const ROOM_WIDTH: int = 16   # tiles
const ROOM_HEIGHT: int = 12  # tiles

var room_width_px: int = ROOM_WIDTH * TILE_SIZE
var room_height_px: int = ROOM_HEIGHT * TILE_SIZE

var floor_texture: Texture2D
var wall_texture: Texture2D
var room_number: int = 1
var is_boss_room: bool = false
var clearing_room: bool = false

@onready var tile_map: TileMap = $TileMap
@onready var enemy_container: Node2D = $EnemyContainer
@onready var item_container: Node2D = $ItemContainer

# Tile IDs: 0=floor(walkable), 1=wall(blocked)


func _ready() -> void:
	floor_texture = SpriteGen.gen_tile_floor()
	wall_texture = SpriteGen.gen_tile_wall()
	_build_tile_set()
	EventBus.room_cleared.connect(_on_room_cleared)
	EventBus.boss_defeated.connect(_on_boss_defeated)


func _build_tile_set() -> void:
	var ts := TileSet.new()
	# Add physics layer 0 for wall collision
	ts.add_physics_layer(0)
	ts.set_physics_layer_collision_layer(0, 2)  # Collision layer 2 for walls

	# ── Source 0: Floor ──
	var floor_src := TileSetAtlasSource.new()
	floor_src.texture = floor_texture
	floor_src.texture_region_size = Vector2i(16, 16)
	floor_src.create_tile(Vector2i(0, 0), Vector2i(1, 1))
	ts.add_source(floor_src, 0)

	# ── Source 1: Wall ──
	var wall_src := TileSetAtlasSource.new()
	wall_src.texture = wall_texture
	wall_src.texture_region_size = Vector2i(16, 16)
	wall_src.create_tile(Vector2i(0, 0), Vector2i(1, 1))
	ts.add_source(wall_src, 1)

	# Set tile size
	ts.tile_size = Vector2i(16, 16)

	# Add collision to wall tile (source 1, atlas coords 0,0, alt 0)
	var wall_data: TileData = wall_src.get_tile_data(Vector2i(0, 0), 0)
	if wall_data:
		wall_data.set_collision_polygons_count(0, 1)
		wall_data.add_collision_polygon(0)
		var polygon: PackedVector2Array = PackedVector2Array([
			Vector2(0, 0), Vector2(16, 0), Vector2(16, 16), Vector2(0, 16)
		])
		wall_data.set_collision_polygon_points(0, 0, polygon)

	# Ensure floor has no collision (already the default)

	tile_map.tile_set = ts


func generate_room(room_num: int, boss: bool) -> void:
	clearing_room = true
	room_number = room_num
	is_boss_room = boss

	# Clear old room
	_clear_room()

	# Build floor
	for x in range(ROOM_WIDTH):
		for y in range(ROOM_HEIGHT):
			if _is_wall(x, y):
				tile_map.set_cell(0, Vector2i(x, y), 1, Vector2i(0, 0), 0)
			else:
				tile_map.set_cell(0, Vector2i(x, y), 0, Vector2i(0, 0), 0)

	# Place obstacles (pillars)
	_place_obstacles()

	# Place enemies
	_place_enemies()

	# Place chests
	_place_chests()

	clearing_room = false


func _clear_room() -> void:
	tile_map.clear()
	# Free enemies
	for child in enemy_container.get_children():
		if is_instance_valid(child):
			child.queue_free()
	# Free items/chests
	for child in item_container.get_children():
		if is_instance_valid(child):
			child.queue_free()
	# Remove any gate areas
	for gate in get_tree().get_nodes_in_group("gates"):
		gate.queue_free()


func _is_wall(x: int, y: int) -> bool:
	return x == 0 or x == ROOM_WIDTH - 1 or y == 0 or y == ROOM_HEIGHT - 1


func _place_obstacles() -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var pillar_count: int = rng.randi_range(0, 3)
	var placed: int = 0
	var attempts: int = 0

	while placed < pillar_count and attempts < 20:
		attempts += 1
		var px: int = rng.randi_range(2, ROOM_WIDTH - 3)
		var py: int = rng.randi_range(2, ROOM_HEIGHT - 3)
		# Keep spawn area clear
		if absi(px - ROOM_WIDTH / 2) < 3 and absi(py - ROOM_HEIGHT / 2) < 3:
			continue
		tile_map.set_cell(0, Vector2i(px, py), 1, Vector2i(0, 0), 0)
		placed += 1


func _place_enemies() -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()

	var enemy_count: int
	if is_boss_room:
		enemy_count = 1  # Boss only
	else:
		enemy_count = clampi(rng.randi_range(2, 4) + room_number / 3, 2, 8)

	for i in range(enemy_count):
		var ex: int = rng.randi_range(2, ROOM_WIDTH - 3)
		var ey: int = rng.randi_range(2, ROOM_HEIGHT - 3)
		var pos: Vector2 = Vector2(ex * TILE_SIZE + TILE_SIZE / 2, ey * TILE_SIZE + TILE_SIZE / 2)

		var enemy_scene: PackedScene = preload("res://scenes/enemy.tscn")
		var enemy: EnemyBase = enemy_scene.instantiate()

		if is_boss_room:
			enemy.enemy_type = EnemyBase.EnemyType.BOSS
			enemy.hp = 500
			enemy.collision_damage = 20
			enemy.move_speed = 80.0
		else:
			var type_roll: int = rng.randi_range(0, 2)
			enemy.enemy_type = type_roll
			if type_roll == EnemyBase.EnemyType.MOLD_SLIME:
				enemy.hp = 120
				enemy.collision_damage = 15
				enemy.move_speed = 60.0
			elif type_roll == EnemyBase.EnemyType.SPICY_GHOST:
				enemy.hp = 50
				enemy.collision_damage = 10
				enemy.move_speed = 140.0
			else:
				enemy.hp = 60
				enemy.collision_damage = 5
				enemy.move_speed = 80.0

		enemy.position = pos
		enemy_container.add_child(enemy)


func _place_chests() -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var chest_count: int = rng.randi_range(0, 2)
	var chest_scene: PackedScene = preload("res://scenes/items/chest.tscn")

	for i in range(chest_count):
		var cx: int = rng.randi_range(2, ROOM_WIDTH - 3)
		var cy: int = rng.randi_range(2, ROOM_HEIGHT - 3)
		var pos: Vector2 = Vector2(cx * TILE_SIZE + TILE_SIZE / 2, cy * TILE_SIZE + TILE_SIZE / 2)
		var chest: Area2D = chest_scene.instantiate()
		chest.position = pos
		item_container.add_child(chest)


func _spawn_gate() -> void:
	var gate_sprite := Sprite2D.new()
	gate_sprite.texture = SpriteGen.gen_gate()
	gate_sprite.add_to_group("gates")
	gate_sprite.z_index = 5
	var gate_pos: Vector2 = Vector2(room_width_px / 2, TILE_SIZE * 2 + TILE_SIZE / 2)
	gate_sprite.position = gate_pos

	var gate_area: Area2D = Area2D.new()
	gate_area.add_to_group("gates")
	var collision: CollisionShape2D = CollisionShape2D.new()
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = Vector2(32, 32)
	collision.shape = shape
	gate_area.add_child(collision)
	gate_area.position = gate_pos

	gate_area.body_entered.connect(_on_gate_entered)
	add_child(gate_area)
	add_child(gate_sprite)


func _on_gate_entered(body: Node2D) -> void:
	if body is PlayerBase:
		# Proceed to next room
		GameManager.next_room()
		var next_boss: bool = GameManager.is_boss_room
		generate_room(GameManager.current_room, next_boss)
		body.position = Vector2(room_width_px / 2, room_height_px - 2 * TILE_SIZE)


func _on_room_cleared() -> void:
	if clearing_room:
		return
	_spawn_gate()


func _on_boss_defeated() -> void:
	if clearing_room:
		return
	_spawn_gate()
	var tween: Tween = create_tween()
	tween.tween_interval(1.5)
	tween.tween_callback(func() -> void:
		get_tree().change_scene_to_file("res://scenes/ui/game_over.tscn")
	)
