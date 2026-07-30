class_name JumpState
extends State
## Manages vertical jump dynamics and air control.


## Buffer time window for initial jump registration.
const CAN_JUMP_TIME: float = 0.05

## Upward velocity force applied during a jump execution.
@export var jump_force: float = -415.0

var _jump_start_timer: float = 0.0
var _consumed_entry_press: bool = false


func enter() -> void:
	_do_jump()
	_consumed_entry_press = true


func physics_update(delta: float) -> State:
	_jump_start_timer += delta
	actor.velocity.y += actor.get_gravity().y * delta

	var direction: float = Input.get_axis("move_left", "move_right")
	actor.velocity.x = direction * actor.speed
	if direction != 0.0:
		actor.is_right = (direction > 0.0)

	if _consumed_entry_press:
		_consumed_entry_press = false
	elif actor.jump_count > 0 and Input.is_action_just_pressed("jump"):
		_do_jump()
		return null

	if Input.is_action_just_pressed("attack"):
		return actor.jump_attack

	actor.move_and_slide()

	if actor.velocity.y > 0.0:
		return actor.fall
	if actor.is_on_floor():
		actor.jump_count = actor.MAX_JUMPS
		return actor.idle

	return null


## Resets timer, applies upward force, updates sprite, and decrements jump counter
func _do_jump() -> void:
	_jump_start_timer = 0.0
	actor.velocity.y = jump_force
	actor.sprite.play("jump")
	actor.jump_count -= 1
