extends Node3D


@onready var drag_plane: DragPlaneArbitrary = $DragPlaneArbitrary
@onready var ball: StaticBody3D = $ball

@onready var dt := DrawTool3D.new()


func _ready() -> void:
	ball.input_event.connect(_on_ball_input_event)
	add_child(drag_plane)
	add_child(dt)
	dt.draw_line(Vector3(-100, 0, 0), Vector3(100, 0, 0), Color.RED)
	dt.draw_line(Vector3(0, -100, 0), Vector3(0, 100, 0), Color.GREEN)
	dt.draw_line(Vector3(0, 0, -100), Vector3(0, 0, 100), Color.BLUE)


func _on_ball_input_event(camera:Node, event:InputEvent, event_position:Vector3, click_normal:Vector3, shape_idx:int) -> void:
	if not event is InputEventMouseButton: return
	if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# turn off input events on the dragged obejct while it's being dragged
		ball.input_ray_pickable = false

		if false:
			# test dragging on a single axis
			var axis := ball.basis.z
			#if debugging:
				#var line_dir := ball.global_position+axis*100
				#debug_dt.draw_line(-line_dir, line_dir, Color.AZURE, 1)
			drag_plane.start_dragging(ball.global_position, axis)

		else:
			# test dragging on two axes
			var axis1 := ball.basis.x
			var axis2 := ball.basis.z
			drag_plane.start_dragging(ball.global_position, axis1, axis2)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and not event.pressed:
		drag_plane.stop_dragging()
		ball.input_ray_pickable = true
	elif event is InputEventMouseMotion:
		if drag_plane.is_dragging:
			ball.global_position = drag_plane.get_drag_position()
