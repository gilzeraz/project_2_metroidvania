class_name SpecialState
extends State


func enter() -> void:
	player.velocity.x = 0
	player.can_change_state = false
	player.sprite.play("attack_special")
	await player.sprite.animation_finished
	state_machine.change_state(player.idle)


func exit() -> void:
	player.can_change_state = true
