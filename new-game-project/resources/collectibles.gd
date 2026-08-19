class_name Collectible
extends Area2D
## Represents a pickup in the world that applies an item's effect to the player on contact.
##
## Reads its visual and effect data from an injected ItemData resource, allowing a single
## scene to represent any collectible type (health, mana, currency) without additional scripts.


## Resource describing this collectible's identity, visuals, and effect.
@export var item_data: ItemData

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	sprite.sprite_frames = item_data.sprite_frames
	sprite.play("default")
	body_entered.connect(_on_body_entered)


## Applies the collectible's effect to the player and removes it from the scene.
func _on_body_entered(body: Node2D) -> void:
	Player.player.apply_item(item_data)
	queue_free()
