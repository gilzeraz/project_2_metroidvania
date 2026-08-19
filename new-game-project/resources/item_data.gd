class_name ItemData
extends Resource
## Defines the identity, visuals, and effect of a collectible item.
##
## A single ItemData instance can be referenced by multiple Collectible nodes in the world,
## keeping the definition shared.


## Which player stat this item affects when collected.
enum EffectType {
	## Restores the player's health, clamped to max_health.
	HEAL,
	## Restores the player's mana, clamped to max_mana.
	MANA,
	## Adds to the player's coin count, uncapped.
	CURRENCY,
}

@export var id: StringName
@export var display_name: String
@export var sprite_frames: SpriteFrames
@export var effect: EffectType
@export var value: int
