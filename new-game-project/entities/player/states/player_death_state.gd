class_name DeathState
extends State
## Controls character death sequence and respawn flow.


func enter() -> void:
	actor.velocity.x = 0.0
	actor.can_change_state = false
	actor.sprite.play("death")

	await actor.sprite.animation_finished

	state_machine.change_state(actor.idle)


func exit() -> void:
	actor.can_change_state = true
