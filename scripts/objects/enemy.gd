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
class_name Enemy
extends CharacterBody3D

#region Exports
## Movement speed when enemy is on the ground 
@export var ground_speed: float = 0
## Specifies the gravity [b]acceleration[/b] vector, in SI units
@export_custom(PROPERTY_HINT_ARRAY_TYPE, "suffix: m/sec^2") var gravity_pull := Vector3(0, -10, 0) 
## Specifies some stats for the enemy
@export var enemy_stats: BasicEnemyStats
#endregion

#region Public variables
var current_collider: KinematicCollision3D
#endregion

#region Private variables
var _move_direction := Vector2(1, 1)
#endregion

#region Subnodes
#@onready var _mesh := $mesh as MeshInstance3D
@onready var _timer := $mov_decision_timer as Timer
@onready var _pointer_mesh := $pointer_mesh as MeshInstance3D
@onready var _fsm := $behaviour as BasicFSM
#endregion

func _ready() -> void:
	randomize()
	self._timer.wait_time = self.enemy_stats.move_decision_wait
	self._timer.start()
	
	var states: Dictionary = self._fsm.fsm_descriptor.registered_states
	# initial state initialization
	states.initial = {
		"path": "initial",
		"condition": self._test_condition,
		"execution": self._regular_movement,
		"transition": null,
	}
	# state machine initialization
	self._fsm.begin()


func _physics_process(delta: float) -> void:
	var displacement := Vector3(0, 0, 0)
	# Displacement due to ground speed and gravity
	displacement = self.velocity*delta + 0.5*self.gravity_pull*delta**2
	# Velocity increase (or decrease) due to gravity
	self.velocity += self.gravity_pull*delta
	
	self.current_collider = self.move_and_collide(displacement)

#region BEHAVIOUR STATES 
# initial state (regular movement state)
func _regular_movement() -> void:
	#player collides with something
	if self.current_collider != null:
		if (self.current_collider.get_collider() as Node3D).is_in_group("ground"):
			self.velocity.y = 0
			# Vectors on the xz plane
			var front_vector := Vector3(self._pointer_mesh.position.x, 0, self._pointer_mesh.position.z)
			var perp_vector := front_vector.cross(self.current_collider.get_normal()).normalized()
			var plane_front_vector := perp_vector.cross(self.current_collider.get_normal()).normalized()
			# Movement on the ground
			self.velocity = -self.ground_speed*( self._move_direction.x*plane_front_vector 
					+ self._move_direction.y*perp_vector )


func _test_condition() -> String:
	return "" # only one state
#endregion

func _on_mov_decision_timer_timeout() -> void:
	self._move_direction = Vector2(cos(randi()), sin(randi()))
