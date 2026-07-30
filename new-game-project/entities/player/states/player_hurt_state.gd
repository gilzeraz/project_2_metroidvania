class_name HurtState
extends State
## Controls hurt reaction behavior and hit-flash shader effects.


## Duration in seconds for each flash pulse in the hit-flash shader.
const SHADER_TIME: float = 0.07


func enter() -> void:
	actor.velocity.x = 0.0
	actor.can_change_state = false

	var tween: Tween = create_tween()
	tween.tween_property(actor.sprite, "material:shader_parameter/flash_amount", 1.0, SHADER_TIME)
	tween.tween_property(actor.sprite, "material:shader_parameter/flash_amount", 0.0, SHADER_TIME)
	tween.tween_property(actor.sprite, "material:shader_parameter/flash_amount", 1.0, SHADER_TIME)
	tween.tween_property(actor.sprite, "material:shader_parameter/flash_amount", 0.0, SHADER_TIME)

	actor.sprite.play("hurt")

	await actor.sprite.animation_finished
	state_machine.change_state(actor.idle)


func exit() -> void:
	actor.can_change_state = true
