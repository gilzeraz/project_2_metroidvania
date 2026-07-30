class_name IdleState
extends State
## Represents the default standing state of the actor.


func enter() -> void:
	actor.velocity.x = 0.0
	actor.sprite.play("idle")
	actor.move_and_slide()


func physics_update(delta: float) -> State:
	actor.velocity.y += actor.get_gravity().y * delta

	if Input.is_action_just_pressed("jump"):
		return actor.jump

	if Input.get_axis("move_left", "move_right") != 0.0:
		return actor.run

	actor.move_and_slide()

	return null
