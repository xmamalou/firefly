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
@export_category("Movement")
@export_range(1, 40, 1, "suffix:m/sec") var ground_speed: int = 10 ## Specifies the speed of the player when moving on the ground, in SI units
@export_range(1, 10, 1, "suffix:m/sec") var vertical_speed: int = 2 ## Specifies the speed of the player when jumping, in SI units
@export_range(1, 10, 1, "suffix:m/sec^2") var gravity_pull: int = 10 ## Specifies the strength of a homogenous gravitational field pulling "down", in SI units
@export var spawn_point: Node3D ## Specifies a spawn point for the player, in case they are killed
#endregion

# Private variables
#var _tolerance_margin: float = 0.05 ## Specifes a margin where the player is considered to move "practically" orthogonally to a collision object 

#region Onready variables
@onready var camera := $center/camera as PlayerCamera ## The camera the player controls
@onready var center := $center as Node3D ## The center that the camera follows
@onready var mesh := $mesh as MeshInstance3D ## The mesh representing the player
#endregion

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	self.position = self.spawn_point.position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	# We track the old velocity for the signal to be emitted
	var old_velocity := self.velocity
	
	var displacement := Vector3(0, 0, 0)
	# Displacement due to ground speed and gravity
	displacement = self.velocity*delta - 0.5*self.gravity_pull*delta**2*Vector3(0, 1, 0)
	# Velocity increase (or decrease) due to gravity
	self.velocity.y -= self.gravity_pull*delta
	
	var collision: KinematicCollision3D = self.move_and_collide(displacement)
	# Player collides with something
	if collision:
		# Kill plane
		if (collision.get_collider() as Node3D).is_in_group("kill"):
			self.velocity = Vector3(0, 0, 0)
			self.position = (
					self.spawn_point.position if self.spawn_point
					else Vector3(0, 0, 0))
		# Player cannot move downwards anymore
		# FIXME: Allow player to fall if not falling *on* ground
		# TODO: Maybe add bounce as well - instead of zeroing, sets velocity to some amount
		self.velocity.y = 0
		# Player is on the ground - they can walk around and perform a jump
		if (collision.get_collider() as Node3D).is_in_group("ground"):
			# Vectors on the xz plane
			var front_vector := (self.center.position - Vector3(
					self.camera.position.x,
					self.center.position.y,
					self.camera.position.z)).normalized()
			var perp_vector := front_vector.cross(collision.get_normal()).normalized()
			var plane_front_vector := perp_vector.cross(collision.get_normal()).normalized()
			# Movement on the ground
			var movement: Vector2 = Input.get_vector(
					"move_back", 
					"move_front", 
					"move_right", 
					"move_left")
			self.velocity = -self.ground_speed*( movement.x*plane_front_vector 
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
