class_name Room
extends Node2D

@onready var level_bounds: LevelBounds = $LevelBounds

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	level_bounds.camera = Player.player.camera
	level_bounds.set_limits()
