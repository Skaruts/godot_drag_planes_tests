#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
# MIT License
#
# Copyright (c) 2025 Skaruts
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# # AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
#
#         DragPlaneShape        (version 18)
#
#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
class_name DragPlaneShape
extends StaticBody3D

##
## A utility node for detecting mouse dragging in 3D space.
## [br][br]
##
## A helper node for detecting mouse dragging of 3D objects, to allow moving
## them in one or more axes.
## [br][br]
##


## Will be true while dragging mode is active.
## [br][br]
## This property is read-only.
var is_dragging: bool:
	get: return _is_dragging

## The point where the mouse raycast intersected the plane.
## [br][br]
## This property is read-only.
var intersection: Vector3:
	get: return _intersection


var _axis1        : Vector3
var _axis2        : Vector3
var _target_pos   : Vector3
var _intersection : Vector3
var _collider     : CollisionShape3D
var _is_dragging  : bool

var _debugging    := false
var _dt: DrawTool3D


func _ready() -> void:
	if _debugging:
		_dt = DrawTool3D.new()
		add_child(_dt)

	_collider = CollisionShape3D.new()
	_collider.shape = WorldBoundaryShape3D.new()
	_collider.shape.plane = -Plane.PLANE_XY

	add_child(_collider)
	stop_dragging()


func _input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	_intersection = event_position
	_adjust_facing()


#NOTE: uncommented only for debugging purposes
#func _process(delta: float) -> void:
	#_adjust_facing()


func _set_axis(axis1: Vector3, axis2 := Vector3.ZERO) -> void:
	_axis1 = axis1
	_axis2 = axis2


func _adjust_facing() -> void:
	if _debugging: _dt.clear()
	if _axis1 == Vector3.ZERO: return

	var camera: Camera3D = get_viewport().get_camera_3d()
	var cam_pos:Vector3 = camera.global_position

	var a := cam_pos
	var b := _collider.global_position

	if _axis2 == Vector3.ZERO or _axis2 == _axis1:
		var d := _axis1
		var c := a + ( (b-a).dot(d) / (pow(d.length(), 2))  ) * d
		var up_vec := Vector3.UP if b.direction_to(c) != Vector3.UP else Vector3.RIGHT  # is this ok?
		_collider.look_at(c, up_vec)
	else:
		var cross := _axis1.cross(_axis2)
		var c := _collider.global_position+cross

		if b.direction_to(c).dot(b.direction_to(a)) < 0:
			cross = _axis2.cross(_axis1)
			c = _collider.global_position+cross

		var up_vec := Vector3.UP if cross != Vector3.UP else Vector3.RIGHT  # is this ok?
		_collider.look_at(c, up_vec)



#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=

#		Public API

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
## Initializes dragging mode based on [param target_position]. If [param axis2]
## is ommited, dragging will be calculated along [param axis1], otherwise it
## will be calculated on the ([param axis1], [param axis2]) plane.
## [br][br]
## The parameter [param target_position] must be in global space.
func start_dragging(target_position: Vector3, axis1: Vector3, axis2 := Vector3.ZERO) -> void:
	input_ray_pickable = true
	_is_dragging = true
	_target_pos = target_position
	_collider.transform.basis = Basis()
	_collider.global_position = target_position
	_set_axis(axis1, axis2)
	_adjust_facing()


## Ends dragging mode.
func stop_dragging() -> void:
	_is_dragging = false
	input_ray_pickable = false


## Returns the position where the object at [param position] is being dragged to.
func get_drag_position() -> Vector3:
	if _axis2 == Vector3.ZERO or _axis2 == _axis1:
		var a := _target_pos
		var b := _intersection
		var d := _axis1
		var c := a + ( (b-a).dot(d) / (pow(d.length(), 2))  ) * d
		return c
	else:
		return _intersection
