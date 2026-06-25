class_name IdleState
extends State

# Idle state.
#
# Stops horizontal movement and plays the idle animation.


func enter() -> void:
	player.velocity.x = 0
	player.sprite.play("idle")
	player.move_and_slide()
	
