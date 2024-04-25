## This is script is an example of how to use the Fog
## This script's scene is 'guard_scene.tscn'
##
## This class extends 'Wanderer' that extends 'RTBrain'
## For this behaviour I want the actor to act the same as a wanderer for most of
## the time, so I am reusing the same implementation and building uppon it

extends Wanderer
class_name Guart

## The target reference, if it finds any
@export var target : EnemySample
## The ShapeCast that will detect the enemies
@export var detection : ShapeCast3D

var attack_timer : float


## CONDITIONS ----------------------------------------------------------------##
func has_target() -> bool:
	return target != null

func its_all_good() -> bool:
	return !has_target()


## STATES ENTERINGS ----------------------------------------------------------##
func attack_enter():
	# starts attacking!
	attack_timer = 1.0


## STATES UPDATES ------------------------------------------------------------##
func attack_update(delta):
	# if somehow it wants to update without a target
	if target==null:
		return
	
	# increment timer
	attack_timer += delta
	
	# check if its time to fire!
	if attack_timer >= 1.0:
		# attack the enemy
		target.damage(2)
		print("Guard: POW!!")
		# reset the timer
		attack_timer = 0.0
	
	if target.dead:
		print("All good now...")
		target = null

## AWAYS ON ------------------------------------------------------------------##
## This secction is to methods that will run independently of the current state
func detect_enemies(physics_delta):
	if target:
		return
	
	if detection.is_colliding():
		for c in range(0, detection.get_collision_count()):
			var collider = detection.get_collider(c)
			if collider is EnemySample and !collider.dead:
				target = collider
	pass

## INITIALIZATION ------------------------------------------------------------##
func _init():
	## REUSING FUNCTIONALITY
	# As I want to reuse all the functionality of the 'Wanderer' I am calling its
	# setup, so the states and transition will be the same as before
	super._init()
	
	# New state
	var attack = create_state('attack').set_enter(attack_enter).set_update(attack_update)
	attack.add_transition_to(IDLE).add_condition(its_all_good)
	
	## ADDING MORE TRANSITIONS
	# Here I'm getting the 'walk_to' state and addind a new transition to the new
	# 'attack' state
	var walk_state = get_state_by_name(WALK_TO)
	walk_state.add_transition_to('attack').add_condition(has_target)
	
	## AWAYS RUNNING METHODS
	# can be assigned connecting them to 'on_physics_update' or 'on_process_update'
	# In this case I want to my guy here to always be looking for surrounding enemies
	on_physics_update.connect(detect_enemies)
