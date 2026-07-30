class_name JumpAttack
extends State
## Controls aerial melee attack behavior and trajectory.


## Default horizontal dash force applied during aerial attack.
const AIR_DASH_FORCE: float = 60.0

## Active duration in seconds for the attack hitbox.
@export var hit_duration: float = 0.15

var _attack_finished: bool = false


func enter() -> void:
	_attack_finished = false
	actor.can_change_state = false
	actor.sprite.play("attack_air")

	if not actor.sprite.animation_finished.is_connected(_on_attack_finished):
		actor.sprite.animation_finished.connect(_on_attack_finished)

	actor.hitbox.activate()


func physics_update(delta: float) -> State:
	if actor.jump_count > 0 and Input.is_action_just_pressed("jump"):
		return actor.jump

	var direction: float = Input.get_axis("move_left", "move_right")
	if direction != 0.0:
		actor.is_right = (direction > 0.0)

	actor.velocity.x = direction * actor.speed
	actor.velocity += actor.get_gravity() * delta
	actor.move_and_slide()

	if _attack_finished:
		return actor.idle if actor.is_on_floor() else actor.fall

	return null


func exit() -> void:
	actor.can_change_state = true
	actor.hitbox.deactivate()
	if actor.sprite.animation_finished.is_connected(_on_attack_finished):
		actor.sprite.animation_finished.disconnect(_on_attack_finished)


func _on_attack_finished() -> void:
	_attack_finished = true
	if actor.sprite.animation_finished.is_connected(_on_attack_finished):
		actor.sprite.animation_finished.disconnect(_on_attack_finished)


## Applies horizontal dash velocity in current facing direction
func _apply_dash() -> void:
	var direction: float = 1.0 if actor.is_right else -1.0
	actor.velocity.x = direction * AIR_DASH_FORCE
