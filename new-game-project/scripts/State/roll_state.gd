class_name RollState
extends State


func enter() -> void:
	player.can_change_state = false
	if player.is_right:
		player.velocity.x = player.ROLL_VELOCITY
	else:
		player.velocity.x = -player.ROLL_VELOCITY
	player.sprite.play("roll")
	await player.sprite.animation_finished
	state_machine.change_state(player.idle)


func physics_update(_delta: float) -> State:
	player.move_and_slide()
	return null


func exit() -> void:
	player.can_change_state = true
