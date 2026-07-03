@tool
class_name LevelBounds
extends Node2D
## Defines rectangular camera limits for a level.
##
## Use this node to set the visible area for a level. The node
## sets the active `Camera2D` limits when the scene is running.


## The width of the level bounds in pixels.
@export_range(1, 4096, 32, "suffix:px") var width: int := 1152 : set = _on_width_changed
## The height of the level bounds in pixels.
@export_range(1, 2048, 32, "suffix:px") var height: int := 648 : set = _on_height_changed


func _ready() -> void:
	z_index = 648

	if Engine.is_editor_hint(): return

	var _camera: Camera2D

	while not _camera:
		await get_tree().process_frame
		if not is_inside_tree(): return
		_camera = get_viewport().get_camera_2d()

	_camera.limit_left = int(global_position.x)
	_camera.limit_top = int(global_position.y)
	_camera.limit_right = int(global_position.x) + width
	_camera.limit_bottom = int(global_position.y) + height


func _draw() -> void:
	if Engine.is_editor_hint():
		var r: Rect2 = Rect2(Vector2.ZERO, Vector2(width, height))
		draw_rect(r, Color(0.0, 0.45, 1.0, 0.6), false, 3)


## Called when the `width` property changes.
func _on_width_changed(new_width: int) -> void:
	width = new_width
	queue_redraw()


## Called when the `height` property changes.
func _on_height_changed(new_height: int) -> void:
	height = new_height
	queue_redraw()
