class_name Projectile
extends Area2D
## Controls projectile movement, directional alignment, damage, and lifespan cleanup.
##
## Translates projectile position along a direction vector, applies collision damage
## upon contact with the player, and auto-frees after a set lifetime duration.


## Movement speed applied to the projectile in pixels per second.
@export var speed: float = 650.0
## Amount of damage inflicted upon colliding with a target entity.
@export var damage: int = 10
## Duration in seconds before the projectile automatically frees itself.
@export var lifetime: float = 3.0

var direction := Vector2.RIGHT


func _ready() -> void:
	rotation = direction.angle()
	body_entered.connect(_on_body_entered)

	_start_lifetime_timer()


func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta


## Updates direction vector and aligns rotation angle accordingly
func set_direction(new_direction: Vector2) -> void:
	direction = new_direction
	rotation = direction.angle()


## Schedules projectile deletion after lifetime duration expires
func _start_lifetime_timer() -> void:
	await get_tree().create_timer(lifetime).timeout

	if is_instance_valid(self):
		queue_free()


## Handles collision responses and damage application upon body overlap
func _on_body_entered(body: Node) -> void:
	if body is Player:
		body.take_damage(damage)

	queue_free()
