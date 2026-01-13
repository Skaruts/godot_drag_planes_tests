extends Node3D


@onready var drag_plane: DragPlaneShapeArbitrary = $DragPlaneShapeArbitrary
@onready var ball: StaticBody3D = $ball

@onready var debug_dt := DrawTool3D.new()
@onready var origin_dt := DrawTool3D.new()
@onready var ball_dt := DrawTool3D.new()

var debugging := false


func _ready() -> void:
	add_child(debug_dt)
	add_child(origin_dt)
	ball.add_child(ball_dt)

	drag_plane.input_event.connect(_on_drag_plane_input_event)
	ball.input_event.connect(_on_ball_input_event)

	origin_dt.draw_line(Vector3(-100, 0, 0), Vector3(100, 0, 0), Color.RED, 0.25)
	origin_dt.draw_line(Vector3(0, -100, 0), Vector3(0, 100, 0), Color.GREEN, 0.25)
	origin_dt.draw_line(Vector3(0, 0, -100), Vector3(0, 0, 100), Color.BLUE, 0.25)

	if debugging:
		ball_dt.draw_line(Vector3.ZERO, Vector3(2, 0, 0), Color.RED, 4)
		ball_dt.draw_line(Vector3.ZERO, Vector3(0, 2, 0), Color.GREEN, 4)
		ball_dt.draw_line(Vector3.ZERO, Vector3(0, 0, 2), Color.BLUE, 4)


func _on_ball_input_event(camera:Node, event:InputEvent, event_position:Vector3, click_normal:Vector3, shape_idx:int) -> void:
	if not event is InputEventMouseButton: return
	if event.pressed:
		ball.input_ray_pickable = false

		if debugging: debug_dt.clear()

		if true:
			# test dragging on a single axis
			var axis := ball.basis.x
			if debugging:
				var line_dir := ball.global_position+axis*100
				debug_dt.draw_line(-line_dir, line_dir, Color.AZURE, 1)
			drag_plane.start_dragging(ball.global_position, axis)

		else:
			# test dragging on two axes
			var axis1 := ball.basis.x
			var axis2 := ball.basis.y
			drag_plane.start_dragging(ball.global_position, axis1, axis2)


func _on_drag_plane_input_event(camera:Node, event:InputEvent, event_position:Vector3, click_normal:Vector3, shape_idx:int) -> void:
	if event is InputEventMouseButton and not event.pressed:
		drag_plane.stop_dragging()
		ball.input_ray_pickable = true
	elif event is InputEventMouseMotion:
		drag_plane.set_target_position(ball)
