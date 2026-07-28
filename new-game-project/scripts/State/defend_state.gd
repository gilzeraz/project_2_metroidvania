class_name DefendState
extends State
## Restricts movement and processes shield block behavior.
##
## Disables state transitions, applies decay to knockback velocity,
## and transitions to idle when the defense input is released.


## Minimum knockback velocity threshold before stopping horizontal movement.
const KNOCKBACK_THRESHOLD: float = 0.1
## Decay factor applied to reduce knockback velocity over time.
const KNOCKBACK_DECAY: float = 0.15
## Default knockback force applied when hit by a direct attacker.
const HEAVY_KNOCKBACK_FORCE: float = 350.0
## Reduced knockback force applied when hit by a projectile or non-entity source.
const LIGHT_KNOCKBACK_FORCE: float = 200.0


var _knockback_velocity: float = 0.0


func enter() -> void:
	actor.can_change_state = false
	actor.velocity.x = 0.0
	_knockback_velocity = 0.0

	actor.is_defending = true

	actor.sprite.play("defend")


func physics_update(_delta: float) -> State:
	if absf(_knockback_velocity) > KNOCKBACK_THRESHOLD:
		actor.velocity.x = _knockback_velocity
		_knockback_velocity = move_toward(_knockback_velocity, 0.0, absf(_knockback_velocity) * KNOCKBACK_DECAY)
	else:
		actor.velocity.x = 0.0

	actor.move_and_slide()

	if not Input.is_action_pressed("defend"):
		return actor.idle

	return null


func exit() -> void:
	actor.can_change_state = true
	actor.is_defending = false


# Calculates and applies horizontal knockback velocity based on attacker position or facing direction
func apply_shield_knockback(attacker: Node2D) -> void:
	var push_direction: float

	if attacker:
		push_direction = 1.0 if actor.global_position.x > attacker.global_position.x else -1.0
		_knockback_velocity = push_direction * HEAVY_KNOCKBACK_FORCE
		return

	push_direction = -1.0 if actor.is_right else 1.0
	_knockback_velocity = push_direction * LIGHT_KNOCKBACK_FORCE
