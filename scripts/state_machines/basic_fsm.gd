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
class_name BasicFSM
extends Node

@export var fsm_descriptor: FSMDescriptor

func _ready() -> void:
	pass

## Every state emits a signal when it is time to transition to a new state.
## The State Machine connects this function to that signal
func _on_state_changed(new_state: String) -> void:
	self.remove_child(self.get_children()[0]) # a state machine always has only one state active
	self._instantiate(new_state)


func _instantiate(state: String) -> void:
	var state_dict: Dictionary = self.fsm_descriptor.registered_states[state] 
	var path := ( self.fsm_descriptor.root_path
			+ state_dict.path + ".gd" ) as String
	var node_type := load(path) as GDScript
	# Set up state and place it in the state machine tree
	var state_inst := node_type.new() as BasicState
	state_inst.condition_callback = state_dict.condition
	if state_dict.execution != null: # there is an execution callback
		state_inst.execution_callback = state_dict.execution
	if state_dict.transition != null: # there is a transition callback
		state_inst.transition_callback = state_dict.transition
	var _ret := state_inst.changed.connect(self._on_state_changed)
	self.add_child(state_inst)

## This function initiates the state machine. Makes sure any 
## parents have correctly configured the state machine
func begin() -> void:
	self._instantiate("initial")
