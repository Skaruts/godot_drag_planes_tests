extends Node3D


@onready var drag_plane := DragPlane.new()
@onready var blue_ball: StaticBody3D = $blue_ball

@onready var dt := DrawTool3D.new()


func _ready() -> void:
	blue_ball.input_event.connect(_on_blue_ball_input_event)
	add_child(drag_plane)
	add_child(dt)
	dt.draw_line(Vector3(-100, 0, 0), Vector3(100, 0, 0), Color.RED)
	dt.draw_line(Vector3(0, -100, 0), Vector3(0, 100, 0), Color.GREEN)
	dt.draw_line(Vector3(0, 0, -100), Vector3(0, 0, 100), Color.BLUE)


func _on_blue_ball_input_event(camera:Node, event:InputEvent, event_position:Vector3, click_normal:Vector3, shape_idx:int) -> void:
	if not event is InputEventMouseButton: return
	if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		blue_ball.input_ray_pickable = false
		#drag_plane.start_dragging(blue_ball.global_position, DragPlane.Axis.Y)
		drag_plane.start_dragging_node(blue_ball, DragPlane.Axis.Y)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and not event.pressed:
		drag_plane.stop_dragging()
		blue_ball.input_ray_pickable = true
	elif event is InputEventMouseMotion:
		if drag_plane.is_dragging:
			drag_plane.compute_intersection()
			#drag_plane.set_target_position(blue_ball)
			#blue_ball.global_position.x = drag_plane.intersection.x
