class_name FSMDescriptor
extends Resource
## A descriptor of an FSM
##
## Describes where the FSM will get its states from and what states it has

#region Exports
## The name of the state machine. Is used to search for its state nodes in the root path
@export var fsm_name: String
## The root path the state machine looks for its states.
## [br][br]
## [b]NOTE:[/b] The state machine looks for its states in the [code]res://<root_path>/<fsm_name>[/code]
## directory!
@export var root_path: String:
	get: return "res://" + root_path + "/" + fsm_name + "/"
## The states the state machine can switch between. 
## Expressed as a dictionary with a string as a key and another Dictionary
## as a value. Requires that there is exactly one key named "initial", 
## which represents the node that will be the initial state.
## [br][br]
## The dictionary value contains three keys; [br]
## - (path) The path of the state template script relative to the state machine's states path (see above) [br]
## - (conditions) The condition callbacks array the state will execute every tick [br]
## - (transition) The transition callback the state will execute when it transitions
@export var registered_states: Dictionary
#endregion

func _init() -> void:
	self.fsm_name = "basic_fsm"
	self.root_path = "scripts/states"
	self.registered_states.initial = { 
		"path": "initial",
		"execution": null,
		"condition": func () -> String: return "",
		"transition": null,
	}
