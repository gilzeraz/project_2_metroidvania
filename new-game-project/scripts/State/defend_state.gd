class_name DefendState
extends State

# Defend (block) state.
#
# Holds blocking pose while defend input is pressed.


func enter() -> void:
	player.can_change_state = false
	player.velocity.x = 0
	player.sprite.play("defend")


func physics_update(_delta: float) -> State:
	player.velocity.x = 0
	if not Input.is_action_pressed("defend"):
		return player.idle
	return null


func exit() -> void:
	player.can_change_state = true
