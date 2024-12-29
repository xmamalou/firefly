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

@icon("res://assets/img/ground_settings.svg")
class_name GroundSettings
extends Resource
## A resource representing properties of a ground object

@export_range(0, 100, 1) var bounce: int ## How much bounce the ground has; is simply a multiplier of the colliding object's velocity
@export_range(0, 100, 1, "suffix:%") var dissipation: float: ## How much of the energy gets absorbed by the object
	get: return (100 - dissipation)/100
	set(value): dissipation = min(100, value) # a negative value is allowed; the ground gives energy to the player
	
func _init() -> void:
	self.bounce = 0
	self.dissipation = 0
