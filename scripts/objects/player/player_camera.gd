# Copyright 2024 Christoforos-Marios Mamaloukas
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

class_name PlayerCamera
extends Camera3D

signal camera_displaced(pos: Vector3)

#region Exports
## If set to true, camera is inverted
@export var is_inverted: bool = false 
## How sensitive the camera is to mouse movements
@export_range(1, 100, 1, "suffix:%") var sensitivity: float = 5 : 
	get: return sensitivity/1000
	set(value): # sensitivity is expressed as a whole percentage (1 to 100, no decimals)
		sensitivity = max(1, abs(ceil(value))) # if value == 0, then 1 is chosen instead
#endregion

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var change := (event as InputEventMouseMotion).relative
		var d_azimuth := self.sensitivity*change.x
		var d_alt := self.sensitivity*change.y
		self._rotate_cam(
				Vector2(d_azimuth, d_alt))
		self.camera_displaced.emit(self.position)


## [font=res://assets/fonts/inter.ttf]
## Rotate the camera according to an azimuth and altitude angle
## [br]
## [b]PARAMETERS[/b][br]
## - [param d_angle]: a 2D vector, where [param x] is the azimuth angle and [param y] the altitude angle
## [/font]
func _rotate_cam(d_angle: Vector2) -> void:
	var future_theta: float = acos(Vector3(self.position.x, 0, self.position.z).normalized().dot(
			self.position.normalized())) + (d_angle.y if self.is_inverted else -d_angle.y)
	# Rotation
	self.rotation.y += d_angle.x
	self.rotation.x -= ( 
			d_angle.y if abs(future_theta) <= PI/3 and future_theta >= 0
			else 0.0) * (1.0 if self.is_inverted else -1.0)
	# Position
	var plane_vec: Vector3 = Vector3(self.position.x, self.position.y, self.position.z).rotated(
			Vector3(0, self.position.y, 0).normalized(), d_angle.x).rotated(
					Vector3(self.position.x, 0, self.position.z).normalized().cross(
							Vector3(0, 1, 0)), 
							(d_angle.y if abs(future_theta) <= PI/3 and future_theta >= 0
							else 0.0) * (1.0 if self.is_inverted else -1.0))
	self.position = Vector3(plane_vec.x, plane_vec.y, plane_vec.z)
