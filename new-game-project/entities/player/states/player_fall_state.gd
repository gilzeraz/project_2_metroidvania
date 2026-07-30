class_name FallState
extends State
## Controls downward vertical movement and falling dynamics.


func enter() -> void:
	actor.sprite.play("fall")


func physics_update(delta: float) -> State:
	actor.velocity.y += actor.get_gravity().y * delta

	var direction: float = Input.get_axis("move_left", "move_right")
	actor.velocity.x = direction * actor.speed
	if direction != 0.0:
		actor.is_right = (direction > 0.0)
		actor.sprite.flip_h = not actor.is_right

	actor.move_and_slide()

	if Input.is_action_just_pressed("jump") and actor.jump_count > 0:
		return actor.jump

	if Input.is_action_just_pressed("attack"):
		return actor.jump_attack

	if actor.is_on_floor():
		actor.jump_count = actor.MAX_JUMPS
		return actor.idle

	return null
