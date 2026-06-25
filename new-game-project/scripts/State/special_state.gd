class_name SpecialState
extends State

# Special attack state.
#
# Plays the special attack animation and returns to idle when finished.


# Starts the special attack animation and waits for completion
func enter() -> void:
	player.velocity.x = 0
	player.can_change_state = false
	player.sprite.play("attack_special")
	await player.sprite.animation_finished
	state_machine.change_state(player.idle)


# Restores state change ability when leaving the special attack
func exit() -> void:
	player.can_change_state = true
