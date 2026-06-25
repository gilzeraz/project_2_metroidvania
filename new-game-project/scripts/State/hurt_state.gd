class_name HurtState
extends State

# Hurt state placeholder.
#
# Intended for knockback and invulnerability handling when damaged.

# Starts the hurt animation and waits for completion
func enter() -> void:
	player.velocity.x = 0
	player.can_change_state = false
	player.sprite.play("hurt")
	await player.sprite.animation_finished
	state_machine.change_state(player.idle)
	
	
# Restores state change ability when leaving the special attack
func exit() -> void:
	player.can_change_state = true
