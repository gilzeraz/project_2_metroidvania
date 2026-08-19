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

## Internal identifier for this item, used for lookups (e.g. save system, debugging).
@export var id: StringName
## Name shown to the player, if/when a UI displays it.
@export var display_name: String
## Animation set played by the Collectible when this item is placed in the world.
@export var sprite_frames: SpriteFrames
## Which effect this item applies when collected.
@export var effect: EffectType
## Amount applied to the corresponding stat (health, mana, or coins).
@export var value: int
