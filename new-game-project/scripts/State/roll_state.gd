class_name RollState
extends State

# Roll (invulnerability/quick-move) state.
#
# Performs a short movement and returns to idle after the roll animation.


# Begins the roll movement and waits for the roll animation to finish
func enter() -> void:
	player.can_change_state = false
	if player.is_right:
		player.velocity.x = 200
	else:
		player.velocity.x = -200
	player.sprite.play("roll")
	await player.sprite.animation_finished
	state_machine.change_state(player.idle)


# Applies movement during the roll
func physics_update(_delta: float) -> State:
	player.move_and_slide()
	return null


# Restores state change ability on roll exit
func exit() -> void:
	player.can_change_state = true
