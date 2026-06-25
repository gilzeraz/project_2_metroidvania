class_name IdleState
extends State


func enter() -> void:
	player.velocity.x = 0
	player.sprite.play("idle")
	player.move_and_slide()
	
func physics_update(delta: float) -> State:
	player.velocity.y += player.get_gravity().y * delta
	player.move_and_slide()
	return null
