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
class_name BasicState
extends Node
## A basic state template

## A signal emitted when a state is about to change
signal changed(new_state: String)

#region Callbacks
## A callback that executes during the state. It is [color=green]optional[/color].
var execution_callback: Callable
## A callback that checks where a state should transition to. It returns a [code]String[/code]
## that indicates the next key to pick from the [code]registered_states[/code] dictionary.
## It is [color=red]required[/color]
var condition_callback: Callable
## A callback that is called when a state is transitioning. It takes only one argument,
## of type [code]String[/code], which represents the new state, and returns [code]void[/code]. 
## It is [color=green]optional[/color].
var transition_callback: Callable
#endregion


func _physics_process(_delta: float) -> void:
	if self.execution_callback != null:
		self.execution_callback.call()
	
	var path: String = self.condition_callback.call()
	if path != "":
		if self.transition_callback != null:
			self.transition_callback.call(path)
		self.changed.emit(path)
