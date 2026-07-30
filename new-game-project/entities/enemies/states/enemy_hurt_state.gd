class_name EnemyHurtState
extends State
## Controls hurt reaction behavior and knockback deceleration for enemy entities.


## Multiplier factor applied to deceleration speed for horizontal knockback friction.
const KNOCKBACK_FRICTION_MULTIPLIER: float = 4.0

## State to transition to once the hurt animation finishes.
@export var next_state: State
## Initial horizontal velocity applied to the actor when hit.
@export var knockback_speed: float = 120.0

var _is_hurt_finished: bool = false


func enter() -> void:
	_is_hurt_finished = false
	actor.sprite.play("hurt")
	actor.sprite.animation_finished.connect(_on_animation_finished)

	if actor.player_near:
		var push_direction: float = 1.0 if actor.global_position.x > Player.player.global_position.x else -1.0
		actor.velocity.x = push_direction * knockback_speed
		actor.facing_direction = -int(push_direction)


func physics_update(delta: float) -> State:
	if _is_hurt_finished and next_state:
		return next_state

	if not actor.is_on_floor():
		if actor is FlyingMonster: return null
		
		actor.velocity.y += actor.get_gravity().y * delta

	actor.velocity.x = move_toward(
		actor.velocity.x,
		0.0,
		knockback_speed * KNOCKBACK_FRICTION_MULTIPLIER * delta
	)
	actor.move_and_slide()

	return null


func exit() -> void:
	if actor.sprite.animation_finished.is_connected(_on_animation_finished):
		actor.sprite.animation_finished.disconnect(_on_animation_finished)


func _on_animation_finished() -> void:
	if actor.sprite.animation == "hurt":
		_is_hurt_finished = true
