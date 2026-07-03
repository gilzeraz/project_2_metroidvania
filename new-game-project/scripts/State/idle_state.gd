class_name IdleState
extends State


func enter() -> void:
	player.velocity.x = 0
	player.sprite.play("idle")
	player.move_and_slide()
	
func physics_update(delta: float) -> State:
	player.velocity.y += player.get_gravity().y * delta
	if not player.is_on_floor() and Input.is_action_just_pressed("jump"):
		state_machine.change_state(player.jump)
	player.move_and_slide()
	return null
