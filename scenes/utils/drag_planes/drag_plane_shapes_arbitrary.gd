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
class_name DragPlaneShapeArbitrary
extends StaticBody3D

##
## A utility node for detecting mouse dragging in 3D space.
## [br][br]
##
## A helper node for detecting mouse dragging of 3D objects, to allow moving
## them in one or more axes.
## [br][br]
##

## The axes that an object can be dragged on.
#static var Axis : Dictionary[String, Vector3] = {
	#X = Vector3(1,0,0),
	#Y = Vector3(0,1,0),
	#Z = Vector3(0,0,1),
	#XY = Vector3(1,1,0),
	#YZ = Vector3(0,1,1),
	#ZX = Vector3(1,0,1),
#}

## The point where the mouse raycast intersected the plane.
var intersection : Vector3


var _target   : Node3D
var _axis1: Vector3
var _axis2: Vector3
var _collider : CollisionShape3D

#var dt: DrawTool3D

func _ready() -> void:
	#dt = DrawTool3D.new()
	#add_child(dt)
	_collider = CollisionShape3D.new()
	_collider.shape = WorldBoundaryShape3D.new()
	_collider.shape.plane = -Plane.PLANE_XY

	add_child(_collider)
	stop_dragging()


func _input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	intersection = event_position
	_adjust_facing()
	if _target:
		set_target_position(_target)


#func _process(delta: float) -> void:
	#_adjust_facing()


func _set_axis(axis1: Vector3, axis2 := Vector3.ZERO) -> void:
	_axis1 = axis1
	_axis2 = axis2


func _adjust_facing() -> void:
	#dt.clear()
	if _axis1 == Vector3.ZERO: return

	var camera: Camera3D = get_viewport().get_camera_3d()
	var cam_pos:Vector3 = camera.owner.global_position

	var a := cam_pos
	var b := _collider.global_position
	var d := _axis1

	if _axis2 == Vector3.ZERO or _axis2 == _axis1:
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
## Initializes dragging mode based on [param position_], along the [param axis] axis.
## [br][br]
## The [param position_] must be in global space.
func start_dragging(position_: Vector3, axis1: Vector3, axis2 := Vector3.ZERO) -> void:
	input_ray_pickable = true
	_collider.transform.basis = Basis()
	_collider.global_position = position_
	_set_axis(axis1, axis2)
	_adjust_facing()


## Initializes dragging based on the [param node] node, along
## the [param axis] axis.
## [br][br]
## This allows for automatic updating of the node's position while dragging.
func start_dragging_node(node: Node3D, axis1: Vector3, axis2 := Vector3.ZERO) -> void:
	_target = node
	start_dragging(_target.global_position, axis1, axis2)


## Ends dragging mode.
func stop_dragging() -> void:
	input_ray_pickable = false
	_target = null


## Sets the correct position on the [param node] dragged object. If you need
## more control over how this is applied, you can access the 'intersection'
## property directly instead.
func set_target_position(node: Node3D) -> void:
	if _axis2 == Vector3.ZERO or _axis2 == _axis1:
		var a := node.global_position
		var b := intersection
		var d := _axis1
		var c := a + ( (b-a).dot(d) / (pow(d.length(), 2))  ) * d
		node.global_position = c
	else:
		node.global_position = intersection
