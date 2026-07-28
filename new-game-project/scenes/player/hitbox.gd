class_name Hitbox
extends Area2D
## Controls damage delivery and multi-hit prevention for attack areas.
##
## Tracks detected bodies within the collision zone to ensure entities receive
## damage exactly once per activation cycle.


## Amount of damage dealt to entities with a take_damage method.
@export var damage_amount: int = 1


var _already_hit: Array[Node] = []


func _ready() -> void:
	monitoring = false
	body_entered.connect(_on_body_entered)


# Enables detection area and checks for overlapping targets
func activate() -> void:
	_already_hit.clear()
	monitoring = true

	for body: Node in get_overlapping_bodies():
		_try_hit(body)


# Disables detection area and resets damaged target tracking
func deactivate() -> void:
	monitoring = false
	_already_hit.clear()


# Callback triggered when a body enters the detection area
func _on_body_entered(body: Node) -> void:
	_try_hit(body)


# Validates target eligibility and applies damage
func _try_hit(body: Node) -> void:
	if body in _already_hit:
		return

	if body.has_method("take_damage"):
		body.take_damage(damage_amount)
		_already_hit.append(body)
