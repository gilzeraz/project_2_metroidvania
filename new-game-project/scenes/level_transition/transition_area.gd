@tool
class_name TransitionArea
extends Node2D
## A trigger that starts a scene transition when the player enters.
##
## Attach to an Area2D that marks a transition point for levels.


## The size of the transition area's collision shape.
@export var size: Vector2 = Vector2(32.0, 32.0): set = _on_size_changed
## The local spawn position for the player after transition.
@export var spawn_position: Vector2 = Vector2.ZERO: set = _on_spawn_position_changed
## The identifier for this area.
@export var area_id: int = 0

@export_group("Target")
## The scene file to load when triggered.
@export_file("*.tscn") var target_level: String = ""
## The target area id to open in the next scene.
@export var target_area: int = 0

@onready var area_2d: Area2D = $Area2D
@onready var spawn_point: Marker2D = $SpawnPoint
@onready var collision: CollisionShape2D = $Area2D/Collision


func _ready() -> void:
	if Engine.is_editor_hint(): return

	spawn_position = spawn_position
	size = size

	SceneManager.new_scene_ready.connect(_on_new_scene_ready)


func _on_player_entered(node: Node) -> void:
	if node is not Player: return

	SceneManager.transition_scene(target_level, target_area)


func _on_new_scene_ready(target_id: int) -> void:
	if target_id != area_id: return

	var player: Player = Player.player
	player.global_position = spawn_point.global_position


func _on_size_changed(new_size: Vector2) -> void:
	size = new_size
	if not is_node_ready(): return

	collision.shape.size = size


func _on_spawn_position_changed(new_position: Vector2) -> void:
	spawn_position = new_position
	if not is_node_ready(): return

	spawn_point.position = spawn_position
