class_name JumpState
extends State


## Minimum time after jump start before a double-jump is allowed.
const CAN_JUMP: float = 0.05
## Maximum jumps before touching floor again.
const JUMP_QUANTITY: int = 2

var jump_force: float = -400.0
var jump_quant: int = 2
var jump_started: float = 0.0


func enter() -> void:
	jump_started = 0.0
	player.velocity.y = jump_force
	player.sprite.play("jump")
	jump_quant -= 1
	player.move_and_slide()


func physics_update(delta: float) -> State:
	if not player.is_on_floor():
		jump_started += delta
		player.velocity.y += player.get_gravity().y * delta
		var direction: float = Input.get_axis("move_left", "move_right")
		player.velocity.x = direction * player.speed
		player.move_and_slide()
		if direction > 0.0:
			player.sprite.flip_h = false
		else:
			player.sprite.flip_h = true
		if (
			jump_quant > 0
			and not player.is_on_floor()
			and Input.is_action_just_pressed("jump")
			and jump_started > CAN_JUMP
		):
			enter()
			return null

	if not player.is_on_floor() and Input.is_action_just_pressed("attack"):
		player.sprite.play("attack_air")

	if player.is_on_floor():
		jump_quant = JUMP_QUANTITY
		return player.idle

	return null
