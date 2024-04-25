extends Node
class_name RTStateBase

var label : StringName = "State"
## Index at StatMachine's states array
var code : int
## Type of refresh time: NORMAL = process, PHYSYCS = 'physics_process'
var time = RTBrainBase.NORMAL

var transitions : Array[RTTransition]
var s_machine : RTBrainBase

signal on_enter ## Called by the State Machine Brain
signal on_uptade(delta:float) ## Called by the State Machine Brain
signal on_exit ## Called by the State Machine Brain


## Adds a given method to be called when this state turns ACTIVE
func set_enter(callable:Callable) -> RTStateBase:
	on_enter.connect(callable)
	return self

## Adds a given method to be called every process call if this state is ACTIVE
func set_update(callable:Callable) -> RTStateBase:
	on_uptade.connect(callable)
	return self

## Adds a given method to be called before another state become activated
func set_exit(callable:Callable) -> RTStateBase:
	on_exit.connect(callable)
	return self


## Adds a new transition to this state and returns it as a reference for faster
## setup
func add_transition_to(to_state:StringName, label:String='-none-') -> RTTransition:
	var n_transit = RTTransition.new()
	n_transit.to_state = to_state
	transitions.append(n_transit)
	
	if label == '-none-':
		n_transit.label = 'tr_' + str(transitions.size())
	else:
		n_transit.label = label
	return n_transit

## Removes all transitions to a determined state
func remove_transitions_to(to_state:StringName):
	var removed = 0
	for tr in transitions:
		if tr.to_state == to_state:
			transitions.erase(tr)
			removed += 1
	
	print(str("Removed '", removed,"' transitions from '", label, "'!"))
