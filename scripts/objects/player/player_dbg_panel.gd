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

class_name PlayerDbgPanel
extends Control

@export var player: Player ## The player to get the debug data from
@export_range(0, 0.001, 0.0001) var tolerance: float: ## Specifies an error margin where the new speed is considered "practically identical" to the old one
	set(value):
		tolerance = abs(value) # Tolerance shouldn't be a negative number
		
@onready var speed_label := $speed_label as Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	speed_label.text = tr("SPEED_LABEL").format({"speed": "%0.3v" % Vector3(0, 0, 0)})
	
	var _ret := player.speed_changed.connect(_on_speed_changed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _physics_process(_delta: float) -> void:
	pass


func _input(event: InputEvent) -> void:
	if event is InputEventKey and (event as InputEventKey).is_action_pressed("toggle_panel"):
		self.visible = not self.visible


func _on_speed_changed(old_velocity: Vector3, new_velocity: Vector3) -> void:
	if old_velocity.length() + self.tolerance < new_velocity.length():
		self.speed_label.text = tr("SPEED_LABEL").format({"speed":  "%0.3v" % new_velocity})
