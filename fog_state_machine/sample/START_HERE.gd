## This is script is an example of how to use the Fog
## This script's scene is 'simple_scene.tscn'
##
## NOTE that first we must extend the class 'RTBrainBase' (Runtime Brain) to get
## the funcitonality working
extends RTBrainBase
## NOTE Is good to give the class (or brain) a name that discribes its behaviour
class_name Wanderer


## Set the parameters normaly. The ones the State Machine will keep track of
@export_category("Parameters")
@export var wait_time : float = 10.0
@export var wander_radius : float = 10.0

@export_category("Movimentation")
@export var walk_speed : float = 5.0
@export var stop_dist : float = 0.25
@export var acceleration : float = 2.0
@export_range(1.0, 5.0) var deceleration : float = 1.15

@export_category("Scene Setup")
@export var marker : Marker3D
@export var root_node : CharacterBody3D

var curr_speed : float = 0.0
var dist_to_target : float = 0.0

## ((Personal NOTE: My Suggestion is to save the state names as constants so to
## avoid mistyping it later))
const IDLE = 'Idle'
const WALK_TO = "WalkTo"


## NOTE that the organization as follows is only a suggestion of how you can
## layout your brain script

## CONDITIONS -----------------------------------------------------------##
## NOTE that conditions are generaly CALLABLES that RETURN A 'BOOL' value. 
## 'true' meaning that the condition is met and 'false' if not

## ((Personal NOTE: Give some easy and contextualized names))
func time_to_go() -> bool:
	return time_in_state > wait_time

func close_enough() -> bool:
	return dist_to_target <= stop_dist

## ((Personal NOTE: Some times a condition is just calling another but with
## a contextualized name, so it is easier to read after))
func too_much_time_walking() -> bool:
	return time_to_go()

func time_to_stop() -> bool:
	return close_enough() or too_much_time_walking()


## STATES ENTERINGS ----------------------------------------------------------##
## In this case I am placing all 'state_enter' Callables in the same place

## This will be the 'on_enter' method of the state 'idle'
func idle_enter():
	# Pick a waiting time to wait before next movement
	wait_time = randf_range(1.0, 5.0)

## This will be the 'on_enter' method of the state 'walk_to'
func walk_to_enter():
	var new_destination = random_position_inside_radius(wander_radius)
	marker.position = new_destination
	curr_speed = 0.0
	dist_to_target = root_node.position.distance_to(marker.position)


## STATES UPDATES ------------------------------------------------------------##
## F.Y. INFO, as before I decided to gather all the states updates in one place

# This will be the 'on_update' method of the state 'walk_to'
func walk_to_update(delta):
	# Calculate the direction
	var direction = get_flat_direction(root_node.position, marker.position)
	dist_to_target = get_flat_distance(root_node.position, marker.position)
	
	var final_speed : float = lerpf(curr_speed, walk_speed, delta * acceleration)
	final_speed *= maxf(inverse_lerp(0.0, stop_dist * deceleration, dist_to_target), 1.0)
	
	# Move the player
	root_node.velocity = direction * final_speed
	root_node.move_and_slide()


## INITIALIZATION ------------------------------------------------------------##

## ATTENTION: All the states setup should be implemented in the '_init' method
## because all the StateMachine inicialization is made at '_ready'. All the states
## info should be available by then
func _init():
	## TO INITIALIZE A STATE
	# just call 'create_state' parsing a name
	# This will return a State that you can start setting up right away
	var idle = create_state(IDLE).set_enter(idle_enter)
	
	## NOTE THAT TO ADD YOUR CUSTOM STATE
	# you can call the method 'add_state' parsing the custom state as argument
	# e.g.:
	# var my_custom_state = CustomStateClass.new()  *## that exteds from 'RTStateBase'
	# my_custom_state.label = 'CustomState'
	# add_state(my_custom_state)
	#
	# NOTE that in this case you should setup the 'state.label' property by yourself
	
	## TO ADD TRANSITION
	# just call the method 'add_transition_to("next_state_name")' of the State
	# you wanto to add the transition parsing the 'next' state name as argument
	# NOTICE that this method will return back the 'Transition' class that you
	# can start configuring right away via the method 'add_condition' and parsing
	# the correspondent Callables
	idle.add_transition_to(WALK_TO).add_condition(time_to_go)
	
	## NOTICE THE WAY TRANSITIONS CHECK THEIR CONDITIONS
	# can be changed via the 'eval_mode' property. As an EXTRA configuration you
	# can change this ENUM property to either:
	## -- "ANY", to transition if any condition is met or
	## -- "ALL", to transition only if all conditions returned true
	
	# NOTICE that you can add AS MANY CONDITIONS AS YOU LIKE
	# e.g.: transition.add_condition(condition1).add_condition(condition2) [...]
	# and by default the 'eval_mode' property value is 'ANY'
	
	## F.Y. INFO TO RUN NY STATE IN PHYSICS TIME
	# you just need to parse the ENUM 'PHYSICS' as second parameter when creating
	# the state.
	# In this example 'walk_to' will move the actor using physics
	var walk_to = create_state(WALK_TO, PHYSICS).set_enter(walk_to_enter).set_update(walk_to_update)
	walk_to.add_transition_to(IDLE).add_condition(close_enough)


## HELPERS -------------------------------------------------------------------##
## Those are helper methods for this specific behaviour
func random_position_inside_radius(radius:float):
	var x = randf() * 2 - 1
	var y = 0.0
	var z = randf() * 2 - 1
	
	return Vector3(x, y, z).normalized() * radius

## Returns a direction in a plane as a 'Vector3'
func get_flat_direction(from_pos:Vector3, to_pos:Vector3) -> Vector3:
	from_pos.y = 0.0
	to_pos.y = 0.0
	
	var dir = to_pos - from_pos
	return dir.normalized()

## Returns the distance as if all the positions were in the ground (y=0)
func get_flat_distance(pos1:Vector3, pos2:Vector3) -> float:
	pos1.y = 0.0
	pos2.y = 0.0
	return pos1.distance_to(pos2)
