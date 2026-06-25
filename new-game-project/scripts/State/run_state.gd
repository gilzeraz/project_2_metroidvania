class_name RunState
extends State

# Running state.
#
# Applies horizontal movement while on the ground and returns to idle when stopped.


# Plays the running animation when entering the run state
func enter() -> void:
	player.sprite.play("run")


# Applies movement each physics tick and returns to idle when stopped
func physics_update(_delta: float) -> State:
	var direction: float = Input.get_axis("move_left", "move_right")
	player.velocity.x = direction * player.speed
	if direction == 0.0:
		return player.idle
	if direction < 0.0:
		player.is_right = false
	else:
		player.is_right = true
	player.move_and_slide()
	return null


# Called when leaving the run state
func exit() -> void:
	pass
	
	
