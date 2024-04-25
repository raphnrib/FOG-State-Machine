extends Node
class_name RTBrainBase

enum { NORMAL, PHYSICS }

var states : Array[RTStateBase]
var time_in_state : float = 0.0

var initial_state : String = ''
var active_state : RTStateBase
var prev_state : int = -1
var is_physics_time : bool = false

## Called every update frame (may be at physics updated depending on the state)
## right before checking active state's transitions
signal on_state_updated

signal on_process_update(delta) # Called every '_process' call
signal on_physics_update(delta) # Called every '_pysics_process' call


## This function should NOT!! be OVERRITEN
func _ready():
	if states.is_empty():
		printerr("No States were initialized! Make sure to override the '_init()' method on the custom derived class")
		set_process(false)
		return
	
	# States inicializatio
	initialize_all_states()
	
	# If no initial state was set starts with the first by default
	if initial_state.is_empty(): set_active_state(0)
	else: set_active_state_by_name(initial_state)

func _process(delta):
	if !is_physics_time:
		update_state_machine(delta)
	on_process_update.emit(delta)

func _physics_process(delta):
	if is_physics_time:
		update_state_machine(delta)
	on_physics_update.emit(delta)

func update_state_machine(delta:float):
	active_state.on_uptade.emit(delta)
	time_in_state += delta
	on_state_updated.emit()
	
	if active_state.transitions.is_empty():
		push_warning(str("State ", active_state.label, " has no transitions configured!"))
	
	for transition in active_state.transitions:
		if transition.evaluate_conditions() == true:
			set_active_state(transition.to_state_id)
			break


## MAIN ----------------------------------------------------------------------##

## Creates a clean State of type RTStateBase that runs in normal '_process' time
## and adds it to the register 
func create_state(label:StringName, time=NORMAL) -> RTStateBase:
	var new_state = RTStateBase.new()
	new_state.label = label
	new_state.name = label
	new_state.time = time
	
	add_child(new_state)
	states.append(new_state)
	return new_state

## Adds a custom state to the scene tree and the register
func add_state(state_to_add:RTStateBase):
	add_child(state_to_add)
	states.append(state_to_add)
	return state_to_add

## Setup the States and their transitions based on their place on the array
func initialize_all_states():
	var total_states : int = states.size()
	var code : int = 0
	for state in states:
		# state initialization
		state.code = code
		state.s_machine = self
		
		# state transitions initializations
		for transition in state.transitions:
			for id in range(0, total_states):
				if states[id].label == transition.to_state:
					transition.to_state_id = id
					break


## Clear active state info, if any, and activate another state in as active
func set_active_state(id:int):
	# Cleanup the last state if there's any
	if active_state != null:
		active_state.on_exit.emit()
		active_state.name = active_state.label
		prev_state = active_state.code
	
	active_state = states[id]
	active_state.on_enter.emit()
	active_state.name = active_state.label + " [active]"
	
	time_in_state = 0.0
	is_physics_time = active_state.time == PHYSICS

## For easier to remember access and setup of the active
func set_active_state_by_name(label:StringName):
	for id in range(0, states.size()):
		if states[id].label == label:
			set_active_state(id)
			return

## Goes back to previus state
func go_to_prev_state():
	if prev_state == -1:
		printerr("Tried to go back to previus state but it didn't existed!")
	else:
		var this_state = active_state.code
		set_active_state(prev_state)
		prev_state = this_state

## HELPERS -------------------------------------------------------------------##


func get_state_by_name(state_name:StringName) -> RTStateBase:
	for state in states:
		if state.label == state_name:
			return state
	printerr(str("State '", state_name, "' when calling 'get_state_by_name' method!"))
	return null

## Returns '-1' if no states were found!
func get_state_id(state_name:StringName):
	var state = get_state_by_name(state_name)
	return state.code if state != null else -1
