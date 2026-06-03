extends Area2D
## Bullet/projectile base class. Used by players and enemies.

class_name Bullet

var direction: Vector2 = Vector2.RIGHT
var bullet_speed: float = 350.0
var damage: int = 12
var is_enemy_bullet: bool = false
var bullet_color: Color = Color(1.0, 0.85, 0.0)

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	if is_enemy_bullet:
		collision_layer = 0
		collision_mask = 0  # Handle manually
		body_entered.connect(_on_body_entered)
	else:
		body_entered.connect(_on_enemy_hit)

	# Set visual
	sprite.texture = SpriteGen.gen_bullet()
	sprite.modulate = bullet_color
	area_entered.connect(_on_area_entered)

	# Auto-free after timeout
	await get_tree().create_timer(3.0).timeout
	if is_instance_valid(self):
		queue_free()


func set_direction(dir: Vector2) -> void:
	direction = dir
	rotation = dir.angle()


func set_damage(dmg: int) -> void:
	damage = dmg


func _physics_process(delta: float) -> void:
	position += direction * bullet_speed * delta


func _on_enemy_hit(body: Node) -> void:
	if body.is_in_group("enemies") and not is_enemy_bullet:
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free()


func _on_body_entered(body: Node) -> void:
	if body is PlayerBase and is_enemy_bullet:
		body.take_damage(damage)
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	var parent: Node = area.get_parent()
	if parent and parent.is_in_group("enemies") and not is_enemy_bullet:
		if parent.has_method("take_damage"):
			parent.take_damage(damage)
		queue_free()
