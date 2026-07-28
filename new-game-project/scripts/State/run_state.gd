class_name RunState
extends State
## Controls horizontal movement and running animations.
##
## Updates actor velocity, direction facing, and manages transitions
## to idle, jump, or fall states based on input and floor status.


func enter() -> void:
	actor.sprite.play("run")


func physics_update(delta: float) -> State:
	if Input.is_action_just_pressed("jump"):
		return actor.jump

	if not actor.is_on_floor():
		return actor.fall

	var direction: float = Input.get_axis("move_left", "move_right")
	actor.velocity.x = direction * actor.speed

	if direction == 0.0:
		return actor.idle

	actor.is_right = (direction > 0.0)
	actor.sprite.flip_h = not actor.is_right

	actor.move_and_slide()

	return null


func exit() -> void:
	pass
