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
