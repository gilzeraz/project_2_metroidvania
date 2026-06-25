class_name IdleState
extends State


func enter() -> void:
	player.velocity.x = 0
	player.sprite.play("idle")
	player.move_and_slide()
	
