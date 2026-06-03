extends Node
## SpriteGen: Programmatic sprite generation for all game entities.
## All sprites are drawn in code — zero external assets required.

static func draw_circle(img: Image, center: Vector2i, radius: int, color: Color) -> void:
	var r2: int = radius * radius
	for y in range(-radius, radius + 1):
		for x in range(-radius, radius + 1):
			if x * x + y * y <= r2:
				var px: int = center.x + x
				var py: int = center.y + y
				if px >= 0 and px < img.get_width() and py >= 0 and py < img.get_height():
					img.set_pixel(px, py, color)


static func draw_rect(img: Image, rect: Rect2i, color: Color) -> void:
	for y in range(rect.position.y, rect.position.y + rect.size.y):
		for x in range(rect.position.x, rect.position.x + rect.size.x):
			if x >= 0 and x < img.get_width() and y >= 0 and y < img.get_height():
				img.set_pixel(x, y, color)


static func draw_line(img: Image, from_p: Vector2i, to_p: Vector2i, color: Color) -> void:
	var dx: int = absi(to_p.x - from_p.x)
	var dy: int = absi(to_p.y - from_p.y)
	var sx: int = 1 if from_p.x < to_p.x else -1
	var sy: int = 1 if from_p.y < to_p.y else -1
	var err: int = dx - dy
	var x: int = from_p.x
	var y: int = from_p.y

	while true:
		if x >= 0 and x < img.get_width() and y >= 0 and y < img.get_height():
			img.set_pixel(x, y, color)
		if x == to_p.x and y == to_p.y:
			break
		var e2: int = err * 2
		if e2 > -dy:
			err -= dy
			x += sx
		if e2 < dx:
			err += dx
			y += sy


static func draw_triangle(img: Image, a: Vector2i, b: Vector2i, c: Vector2i, color: Color) -> void:
	var min_x: int = mini(mini(a.x, b.x), c.x)
	var max_x: int = maxi(maxi(a.x, b.x), c.x)
	var min_y: int = mini(mini(a.y, b.y), c.y)
	var max_y: int = maxi(maxi(a.y, b.y), c.y)
	for y in range(min_y, max_y + 1):
		for x in range(min_x, max_x + 1):
			var p: Vector2i = Vector2i(x, y)
			if _point_in_triangle(p, a, b, c):
				if x >= 0 and x < img.get_width() and y >= 0 and y < img.get_height():
					img.set_pixel(x, y, color)


static func draw_rect_border(img: Image, rect: Rect2i, color: Color) -> void:
	# Top and bottom
	for x in range(rect.position.x, rect.position.x + rect.size.x):
		var y_top: int = rect.position.y
		var y_bot: int = rect.position.y + rect.size.y - 1
		if x >= 0 and x < img.get_width():
			if y_top >= 0 and y_top < img.get_height():
				img.set_pixel(x, y_top, color)
			if y_bot >= 0 and y_bot < img.get_height():
				img.set_pixel(x, y_bot, color)
	# Left and right
	for y in range(rect.position.y, rect.position.y + rect.size.y):
		var x_left: int = rect.position.x
		var x_right: int = rect.position.x + rect.size.x - 1
		if y >= 0 and y < img.get_height():
			if x_left >= 0 and x_left < img.get_width():
				img.set_pixel(x_left, y, color)
			if x_right >= 0 and x_right < img.get_width():
				img.set_pixel(x_right, y, color)


static func _point_in_triangle(p: Vector2i, a: Vector2i, b: Vector2i, c: Vector2i) -> bool:
	var d1: float = _sign(p, a, b)
	var d2: float = _sign(p, b, c)
	var d3: float = _sign(p, c, a)
	var has_neg: bool = (d1 < 0.0) or (d2 < 0.0) or (d3 < 0.0)
	var has_pos: bool = (d1 > 0.0) or (d2 > 0.0) or (d3 > 0.0)
	return not (has_neg and has_pos)


static func _sign(p1: Vector2i, p2: Vector2i, p3: Vector2i) -> float:
	return (p1.x - p3.x) * (p2.y - p3.y) - (p2.x - p3.x) * (p1.y - p3.y)


static func _make_texture(size: Vector2i) -> Image:
	var img: Image = Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	return img


static func _img_to_texture(img: Image) -> Texture2D:
	return ImageTexture.create_from_image(img)


# ─── Character Sprites ─────────────────────────────────────────

static func gen_butter_shooter() -> Texture2D:
	var size := Vector2i(32, 32)
	var img: Image = _make_texture(size)
	var center := Vector2i(16, 16)
	# Body - golden yellow circle
	draw_circle(img, center, 12, Color(1.0, 0.85, 0.0))
	# Outline
	draw_circle(img, center, 12, Color(0.8, 0.65, 0.0, 0.3))
	draw_circle(img, center, 11, Color(1.0, 0.85, 0.0))
	# Cannon barrel (top-right)
	draw_rect(img, Rect2i(16, 8, 12, 4), Color(0.9, 0.7, 0.0))
	# Eyes
	draw_circle(img, Vector2i(12, 13), 3, Color(0.2, 0.15, 0.0))
	draw_circle(img, Vector2i(20, 13), 3, Color(0.2, 0.15, 0.0))
	draw_circle(img, Vector2i(13, 12), 1, Color(1, 1, 1))
	draw_circle(img, Vector2i(21, 12), 1, Color(1, 1, 1))
	# Butter drip details
	draw_circle(img, Vector2i(16, 22), 3, Color(1.0, 0.9, 0.2))
	return _img_to_texture(img)


static func gen_ham_warrior() -> Texture2D:
	var size := Vector2i(32, 32)
	var img: Image = _make_texture(size)
	# Body - pink square
	draw_rect(img, Rect2i(6, 6, 20, 20), Color(1.0, 0.7, 0.7))
	draw_rect_border(img, Rect2i(6, 6, 20, 20), Color(0.8, 0.5, 0.5))
	# Shield (left side)
	draw_rect(img, Rect2i(2, 10, 6, 14), Color(0.6, 0.4, 0.3))
	draw_rect_border(img, Rect2i(2, 10, 6, 14), Color(0.4, 0.25, 0.15))
	# Ham lines
	draw_line(img, Vector2i(10, 12), Vector2i(22, 12), Color(0.9, 0.5, 0.5))
	draw_line(img, Vector2i(10, 16), Vector2i(22, 16), Color(0.9, 0.5, 0.5))
	draw_line(img, Vector2i(10, 20), Vector2i(22, 20), Color(0.9, 0.5, 0.5))
	# Eyes
	draw_circle(img, Vector2i(12, 9), 2, Color(0.2, 0.1, 0.1))
	draw_circle(img, Vector2i(20, 9), 2, Color(0.2, 0.1, 0.1))
	# Meat hammer (right side)
	draw_rect(img, Rect2i(24, 12, 6, 4), Color(0.7, 0.5, 0.3))
	draw_rect(img, Rect2i(26, 8, 4, 8), Color(0.5, 0.35, 0.2))
	return _img_to_texture(img)


static func gen_lettuce_priest() -> Texture2D:
	var size := Vector2i(32, 32)
	var img: Image = _make_texture(size)
	# Body - green leaf shape
	draw_circle(img, Vector2i(16, 16), 12, Color(0.3, 0.8, 0.3))
	# Leaf veins
	draw_line(img, Vector2i(16, 16), Vector2i(8, 8), Color(0.2, 0.6, 0.2))
	draw_line(img, Vector2i(16, 16), Vector2i(24, 8), Color(0.2, 0.6, 0.2))
	draw_line(img, Vector2i(16, 16), Vector2i(8, 24), Color(0.2, 0.6, 0.2))
	draw_line(img, Vector2i(16, 16), Vector2i(24, 24), Color(0.2, 0.6, 0.2))
	# Leaf tips
	draw_triangle(img, Vector2i(4, 4), Vector2i(8, 8), Vector2i(4, 8), Color(0.2, 0.7, 0.2))
	draw_triangle(img, Vector2i(28, 4), Vector2i(24, 8), Vector2i(28, 8), Color(0.2, 0.7, 0.2))
	draw_triangle(img, Vector2i(4, 28), Vector2i(8, 24), Vector2i(4, 24), Color(0.2, 0.7, 0.2))
	draw_triangle(img, Vector2i(28, 28), Vector2i(24, 24), Vector2i(28, 24), Color(0.2, 0.7, 0.2))
	# Eyes
	draw_circle(img, Vector2i(12, 14), 3, Color(0.1, 0.3, 0.1))
	draw_circle(img, Vector2i(20, 14), 3, Color(0.1, 0.3, 0.1))
	draw_circle(img, Vector2i(13, 13), 1, Color(0.5, 1.0, 0.5))
	draw_circle(img, Vector2i(21, 13), 1, Color(0.5, 1.0, 0.5))
	# Staff
	draw_line(img, Vector2i(26, 6), Vector2i(26, 26), Color(0.5, 0.35, 0.2))
	draw_circle(img, Vector2i(26, 6), 3, Color(0.2, 0.9, 0.2))
	return _img_to_texture(img)


# ─── Enemy Sprites ─────────────────────────────────────────────

static func gen_enemy_mold_slime() -> Texture2D:
	var size := Vector2i(28, 28)
	var img: Image = _make_texture(size)
	# Dark green blob
	draw_circle(img, Vector2i(14, 16), 12, Color(0.2, 0.55, 0.15))
	draw_circle(img, Vector2i(14, 16), 11, Color(0.25, 0.6, 0.18))
	# Eyes
	draw_circle(img, Vector2i(10, 14), 3, Color(0.9, 0.9, 0.9))
	draw_circle(img, Vector2i(18, 14), 3, Color(0.9, 0.9, 0.9))
	draw_circle(img, Vector2i(10, 14), 1, Color(0.1, 0.3, 0.1))
	draw_circle(img, Vector2i(18, 14), 1, Color(0.1, 0.3, 0.1))
	# Mold spots
	draw_circle(img, Vector2i(8, 20), 3, Color(0.15, 0.4, 0.1))
	draw_circle(img, Vector2i(20, 18), 2, Color(0.15, 0.4, 0.1))
	return _img_to_texture(img)


static func gen_enemy_spicy_ghost() -> Texture2D:
	var size := Vector2i(28, 28)
	var img: Image = _make_texture(size)
	# Semi-transparent red ghost body
	var red_semi: Color = Color(1.0, 0.2, 0.1, 0.7)
	draw_circle(img, Vector2i(14, 12), 10, red_semi)
	draw_rect(img, Rect2i(4, 12, 20, 10), red_semi)
	# Wavy bottom
	draw_circle(img, Vector2i(6, 20), 4, red_semi)
	draw_circle(img, Vector2i(14, 22), 4, red_semi)
	draw_circle(img, Vector2i(22, 20), 4, red_semi)
	# Flame eyes
	draw_circle(img, Vector2i(10, 11), 3, Color(1.0, 0.9, 0.0))
	draw_circle(img, Vector2i(18, 11), 3, Color(1.0, 0.9, 0.0))
	draw_circle(img, Vector2i(10, 11), 1, Color(1.0, 0.4, 0.0))
	draw_circle(img, Vector2i(18, 11), 1, Color(1.0, 0.4, 0.0))
	# Mouth
	draw_line(img, Vector2i(10, 17), Vector2i(18, 17), Color(1.0, 0.5, 0.0, 0.8))
	return _img_to_texture(img)


static func gen_enemy_cheese_demon() -> Texture2D:
	var size := Vector2i(28, 28)
	var img: Image = _make_texture(size)
	# Yellow demon body
	draw_circle(img, Vector2i(14, 14), 12, Color(1.0, 0.8, 0.1))
	draw_circle(img, Vector2i(14, 14), 11, Color(1.0, 0.85, 0.2))
	# Horns
	draw_triangle(img, Vector2i(6, 2), Vector2i(10, 10), Vector2i(4, 10), Color(0.9, 0.7, 0.0))
	draw_triangle(img, Vector2i(22, 2), Vector2i(24, 10), Vector2i(18, 10), Color(0.9, 0.7, 0.0))
	# Eyes
	draw_circle(img, Vector2i(10, 12), 3, Color(0.8, 0.1, 0.1))
	draw_circle(img, Vector2i(18, 12), 3, Color(0.8, 0.1, 0.1))
	draw_circle(img, Vector2i(11, 11), 1, Color(1.0, 0.3, 0.3))
	draw_circle(img, Vector2i(19, 11), 1, Color(1.0, 0.3, 0.3))
	# Cheese holes
	draw_circle(img, Vector2i(10, 18), 2, Color(0.9, 0.75, 0.05))
	draw_circle(img, Vector2i(18, 19), 2, Color(0.9, 0.75, 0.05))
	draw_circle(img, Vector2i(14, 20), 1, Color(0.9, 0.75, 0.05))
	return _img_to_texture(img)


static func gen_enemy_boss() -> Texture2D:
	var size := Vector2i(48, 48)
	var img: Image = _make_texture(size)
	# Dark purple large body
	draw_circle(img, Vector2i(24, 24), 22, Color(0.4, 0.1, 0.4))
	draw_circle(img, Vector2i(24, 24), 21, Color(0.5, 0.15, 0.5))
	draw_circle(img, Vector2i(24, 24), 20, Color(0.45, 0.12, 0.45))
	# Crown
	draw_triangle(img, Vector2i(14, 6), Vector2i(24, 14), Vector2i(10, 14), Color(0.9, 0.7, 0.0))
	draw_triangle(img, Vector2i(34, 6), Vector2i(38, 14), Vector2i(24, 14), Color(0.9, 0.7, 0.0))
	draw_rect(img, Rect2i(14, 6, 20, 4), Color(0.9, 0.7, 0.0))
	# Eyes
	draw_circle(img, Vector2i(18, 20), 5, Color(1.0, 0.1, 0.1))
	draw_circle(img, Vector2i(30, 20), 5, Color(1.0, 0.1, 0.1))
	draw_circle(img, Vector2i(18, 20), 2, Color(1.0, 1.0, 1.0))
	draw_circle(img, Vector2i(30, 20), 2, Color(1.0, 1.0, 1.0))
	# Mouth
	draw_rect(img, Rect2i(16, 30, 16, 4), Color(0.6, 0.05, 0.2))
	# Dark aura rings
	draw_circle(img, Vector2i(24, 24), 22, Color(0.2, 0.05, 0.2, 0.3))
	return _img_to_texture(img)


# ─── Item & Tile Sprites ──────────────────────────────────────

static func gen_chest() -> Texture2D:
	var size := Vector2i(24, 24)
	var img: Image = _make_texture(size)
	# Brown chest body
	draw_rect(img, Rect2i(4, 8, 16, 12), Color(0.6, 0.35, 0.15))
	draw_rect_border(img, Rect2i(4, 8, 16, 12), Color(0.4, 0.2, 0.1))
	# Lid
	draw_rect(img, Rect2i(3, 5, 18, 5), Color(0.7, 0.4, 0.2))
	draw_rect_border(img, Rect2i(3, 5, 18, 5), Color(0.5, 0.25, 0.1))
	# Gold lock
	draw_rect(img, Rect2i(10, 12, 4, 4), Color(0.9, 0.75, 0.0))
	draw_circle(img, Vector2i(12, 14), 2, Color(0.8, 0.6, 0.0))
	return _img_to_texture(img)


static func gen_bullet() -> Texture2D:
	var size := Vector2i(8, 8)
	var img: Image = _make_texture(size)
	draw_circle(img, Vector2i(4, 4), 3, Color(1.0, 0.85, 0.0))
	draw_circle(img, Vector2i(4, 4), 2, Color(1.0, 0.95, 0.3))
	return _img_to_texture(img)


static func gen_lettuce_projectile() -> Texture2D:
	var size := Vector2i(10, 10)
	var img: Image = _make_texture(size)
	# Green leaf shape
	draw_circle(img, Vector2i(5, 5), 4, Color(0.2, 0.75, 0.2))
	draw_triangle(img, Vector2i(1, 3), Vector2i(5, 5), Vector2i(1, 7), Color(0.15, 0.6, 0.15))
	draw_triangle(img, Vector2i(9, 3), Vector2i(5, 5), Vector2i(9, 7), Color(0.15, 0.6, 0.15))
	return _img_to_texture(img)


static func gen_cheese_projectile() -> Texture2D:
	var size := Vector2i(10, 10)
	var img: Image = _make_texture(size)
	# Yellow ellipsoid
	draw_circle(img, Vector2i(5, 5), 4, Color(1.0, 0.8, 0.1))
	draw_circle(img, Vector2i(5, 5), 3, Color(1.0, 0.9, 0.3))
	# Cheese hole
	draw_circle(img, Vector2i(5, 5), 1, Color(0.9, 0.75, 0.05))
	return _img_to_texture(img)


static func gen_tile_wall() -> Texture2D:
	var size := Vector2i(16, 16)
	var img: Image = _make_texture(size)
	# Stone wall
	draw_rect(img, Rect2i(0, 0, 16, 16), Color(0.45, 0.45, 0.5))
	draw_rect_border(img, Rect2i(0, 0, 16, 16), Color(0.3, 0.3, 0.35))
	# Stone lines
	draw_line(img, Vector2i(0, 7), Vector2i(16, 7), Color(0.35, 0.35, 0.4))
	draw_line(img, Vector2i(8, 0), Vector2i(8, 7), Color(0.35, 0.35, 0.4))
	draw_line(img, Vector2i(4, 7), Vector2i(4, 16), Color(0.35, 0.35, 0.4))
	draw_line(img, Vector2i(12, 7), Vector2i(12, 16), Color(0.35, 0.35, 0.4))
	# Shadow/highlight
	draw_rect(img, Rect2i(0, 0, 16, 1), Color(0.5, 0.5, 0.55))
	draw_rect(img, Rect2i(0, 15, 16, 1), Color(0.3, 0.3, 0.35))
	return _img_to_texture(img)


static func gen_tile_floor() -> Texture2D:
	var size := Vector2i(16, 16)
	var img: Image = _make_texture(size)
	# Wooden floor
	draw_rect(img, Rect2i(0, 0, 16, 16), Color(0.55, 0.4, 0.25))
	# Wood grain
	draw_line(img, Vector2i(0, 4), Vector2i(16, 4), Color(0.5, 0.35, 0.2))
	draw_line(img, Vector2i(0, 8), Vector2i(16, 8), Color(0.5, 0.35, 0.2))
	draw_line(img, Vector2i(0, 12), Vector2i(16, 12), Color(0.5, 0.35, 0.2))
	# Variations
	draw_line(img, Vector2i(3, 1), Vector2i(3, 3), Color(0.5, 0.35, 0.2))
	draw_line(img, Vector2i(11, 5), Vector2i(11, 7), Color(0.5, 0.35, 0.2))
	draw_line(img, Vector2i(7, 9), Vector2i(7, 11), Color(0.5, 0.35, 0.2))
	return _img_to_texture(img)


static func gen_health_potion() -> Texture2D:
	var size := Vector2i(16, 16)
	var img: Image = _make_texture(size)
	# Red potion bottle
	draw_rect(img, Rect2i(5, 3, 6, 10), Color(0.8, 0.15, 0.15))
	draw_rect_border(img, Rect2i(5, 3, 6, 10), Color(0.5, 0.1, 0.1))
	# Bottle neck
	draw_rect(img, Rect2i(6, 1, 4, 3), Color(0.8, 0.15, 0.15))
	draw_rect(img, Rect2i(7, 0, 2, 2), Color(0.9, 0.8, 0.1))
	# Liquid highlight
	draw_rect(img, Rect2i(6, 5, 2, 4), Color(0.9, 0.25, 0.25, 0.5))
	return _img_to_texture(img)


static func gen_attack_potion() -> Texture2D:
	var size := Vector2i(16, 16)
	var img: Image = _make_texture(size)
	# Orange potion bottle
	draw_rect(img, Rect2i(5, 3, 6, 10), Color(0.9, 0.5, 0.05))
	draw_rect_border(img, Rect2i(5, 3, 6, 10), Color(0.6, 0.3, 0.05))
	draw_rect(img, Rect2i(6, 1, 4, 3), Color(0.9, 0.5, 0.05))
	draw_rect(img, Rect2i(7, 0, 2, 2), Color(0.9, 0.8, 0.1))
	draw_rect(img, Rect2i(6, 5, 2, 4), Color(0.95, 0.6, 0.15, 0.5))
	return _img_to_texture(img)


static func gen_defense_potion() -> Texture2D:
	var size := Vector2i(16, 16)
	var img: Image = _make_texture(size)
	# Blue potion bottle
	draw_rect(img, Rect2i(5, 3, 6, 10), Color(0.15, 0.4, 0.8))
	draw_rect_border(img, Rect2i(5, 3, 6, 10), Color(0.1, 0.25, 0.5))
	draw_rect(img, Rect2i(6, 1, 4, 3), Color(0.15, 0.4, 0.8))
	draw_rect(img, Rect2i(7, 0, 2, 2), Color(0.9, 0.8, 0.1))
	draw_rect(img, Rect2i(6, 5, 2, 4), Color(0.3, 0.6, 0.9, 0.5))
	return _img_to_texture(img)


static func gen_speed_potion() -> Texture2D:
	var size := Vector2i(16, 16)
	var img: Image = _make_texture(size)
	# Green potion bottle
	draw_rect(img, Rect2i(5, 3, 6, 10), Color(0.15, 0.7, 0.15))
	draw_rect_border(img, Rect2i(5, 3, 6, 10), Color(0.1, 0.45, 0.1))
	draw_rect(img, Rect2i(6, 1, 4, 3), Color(0.15, 0.7, 0.15))
	draw_rect(img, Rect2i(7, 0, 2, 2), Color(0.9, 0.8, 0.1))
	draw_rect(img, Rect2i(6, 5, 2, 4), Color(0.3, 0.85, 0.3, 0.5))
	return _img_to_texture(img)


static func gen_gate() -> Texture2D:
	var size := Vector2i(24, 24)
	var img: Image = _make_texture(size)
	# Gold glowing portal
	draw_circle(img, Vector2i(12, 12), 11, Color(0.0, 0.0, 0.0, 0.8))
	draw_circle(img, Vector2i(12, 12), 10, Color(0.9, 0.7, 0.0))
	draw_circle(img, Vector2i(12, 12), 8, Color(0.7, 0.5, 0.0))
	draw_circle(img, Vector2i(12, 12), 6, Color(0.9, 0.8, 0.3))
	# Inner glow
	draw_circle(img, Vector2i(12, 12), 4, Color(1.0, 0.95, 0.6))
	return _img_to_texture(img)
