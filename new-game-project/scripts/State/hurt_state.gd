class_name HurtState
extends State


func enter() -> void:
	player.velocity.x = 0
	player.can_change_state = false
	player.sprite.play("hurt")
	await player.sprite.animation_finished
	state_machine.change_state(player.idle)
	
	
func exit() -> void:
	player.can_change_state = true
