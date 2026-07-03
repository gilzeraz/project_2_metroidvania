class_name RunState
extends State


func enter() -> void:
	player.sprite.play("run")


func physics_update(delta: float) -> State:
	if not player.is_on_floor() and Input.is_action_just_pressed("jump"):
		state_machine.change_state(player.jump)
	player.velocity.y += player.get_gravity().y * delta
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


func exit() -> void:
	pass
	
	
