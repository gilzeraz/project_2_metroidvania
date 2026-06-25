class_name DeathState
extends State

# Death state placeholder.
#
# Use to handle death animation and game over transitions.

# Starts the death animation and waits for completion
func enter() -> void:
	player.velocity.x = 0
	player.can_change_state = false
	player.sprite.play("death")
	await player.sprite.animation_finished
	state_machine.change_state(player.idle)


# Restores state change ability when leaving the special attack
func exit() -> void:
	player.can_change_state = true
