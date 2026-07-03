@tool
class_name LevelBounds
extends Node2D
## Defines rectangular camera limits for a level.
##
## Attach to a level root. Sets the active [Camera2D]'s limits
## to match this node's bounds when the scene runs.


## Maximum z_index.
const INDEX: int = 648

## The width of the level bounds in pixels.
@export_range(1, 4096, 32, "suffix:px") var width: int = 1152: set = _on_width_changed
## The height of the level bounds in pixels.
@export_range(1, 2048, 32, "suffix:px") var height: int = 648: set = _on_height_changed

var camera: Camera2D
	

func _ready() -> void:
	z_index = INDEX

	if Engine.is_editor_hint(): return


func set_limits() -> void:
	print(camera)
	camera.limit_left = int(global_position.x)
	camera.limit_top = int(global_position.y)
	camera.limit_right = int(global_position.x) + width
	camera.limit_bottom = int(global_position.y) + height


func _draw() -> void:
	if Engine.is_editor_hint():
		var r: Rect2 = Rect2(Vector2.ZERO, Vector2(width, height))
		draw_rect(r, Color(0.0, 0.45, 1.0, 0.6), false, 3)
		
		
## Called when the [member width] property changes.		
func _on_width_changed(value: int) -> void:
	width = value
	queue_redraw()
	
	
## Called when the [member height] property changes.	
func _on_height_changed(value: int) -> void:
	height = value
	queue_redraw()
