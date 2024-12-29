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
class_name Player
extends CharacterBody3D
## A class representing a player controllable by the user
## 
## [b]Player[/b] is a class representing a player that can move around and jump.
## They have a spawnpoint they spawn from when the game starts or they get killed
## and they are affected by gravity

## A signal emitted when the player changes speed, used for debugging purposes
signal speed_changed(old_speed: Vector3, new_speed: Vector3)

#region Exports
@export_group("Movement")
## Specifies the speed of the player when moving on the ground, in SI units
@export_range(1, 40, 1, "suffix:m/sec") var ground_speed: int = 10 
## Specifies the speed of the player when jumping, in SI units
@export_range(1, 10, 1, "suffix:m/sec") var vertical_speed: int = 2 
## Specifies the gravity [b]acceleration[/b] vector, in SI units
@export_custom(PROPERTY_HINT_ARRAY_TYPE, "suffix: m/sec^2") var gravity_pull := Vector3(0, -10, 0)
## Specifies a spawn point for the player, in case they are killed
@export var spawn_point: Node3D 
# ------------------------
@export_group("Camera")
## If set to true, camera is inverted
@export var is_cam_inverted: bool = false 
## How sensitive the camera is to mouse movements
@export_range(1, 100, 1, "suffix:%") var mouse_sensitivity: float = 5 
#endregion

#region Private variables
## Specifes a margin where the player is considered to move "practically" orthogonally to a collision object 
var _tolerance_margin: float = 0.8
#endregion

#region Subnodes
## The camera the player controls
@onready var _camera := $center/camera as PlayerCamera
## The center that the camera follows
@onready var _center := $center as Node3D 
#@onready var _mesh := $mesh as MeshInstance3D ## The mesh representing the player
#endregion

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	self.position = self.spawn_point.position
	
	self._camera.is_inverted = self.is_cam_inverted
	self._camera.sensitivity = self.mouse_sensitivity


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	# We track the old velocity for the signal to be emitted
	var old_velocity := self.velocity
	
	var displacement := Vector3(0, 0, 0)
	# Displacement due to ground speed and gravity
	displacement = self.velocity*delta + 0.5*self.gravity_pull*delta**2
	# Velocity increase (or decrease) due to gravity
	self.velocity += self.gravity_pull*delta
	
	var collision: KinematicCollision3D = self.move_and_collide(displacement)
	# Player collides with something
	if collision:
		# We want to push the player on the opposite direction
		self.velocity = -collision.get_remainder().normalized()
		var collider := collision.get_collider() as Node3D
		# Kill plane
		if collider.is_in_group("kill"):
			self.velocity = Vector3(0, 0, 0)
			self.position = (
					self.spawn_point.position if self.spawn_point
					else Vector3(0, 0, 0))
		# Player cannot move downwards anymore
		# Player is on the ground - they can walk around and perform a jump
		if collider.is_in_group("ground"): # objects in the `ground` group are GroundBody objects, hence they have the `bounce` property 
			self.velocity *= (collider as GroundBody).bounce*(collider as GroundBody).dissipation*(
					0.0 if abs(self.velocity.y) < self._tolerance_margin else 1.0) # This is to prevent infinite bouncing
			# Vectors on the xz plane
			var front_vector := (self._center.position - Vector3(
					self._camera.position.x,
					self._center.position.y,
					self._camera.position.z)).normalized()
			var perp_vector := front_vector.cross(collision.get_normal()).normalized()
			var plane_front_vector := perp_vector.cross(collision.get_normal()).normalized()
			# Movement on the ground
			var movement: Vector2 = Input.get_vector(
					"move_back", 
					"move_front", 
					"move_right", 
					"move_left")
			self.velocity += -self.ground_speed*( movement.x*plane_front_vector 
					+ movement.y*perp_vector )
			# Jump
			if Input.is_action_pressed("jump"):
				self.velocity.y = self.vertical_speed
	else:
		# Player shouldn't move, but they should be able to break
		if Input.is_action_pressed("move_back"):
			self.velocity.x *= 0.99
			self.velocity.z *= 0.99
	
	speed_changed.emit(old_velocity, self.velocity)


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		match (event as InputEventKey).as_text_key_label():
			"Escape":
				self.get_tree().quit()
