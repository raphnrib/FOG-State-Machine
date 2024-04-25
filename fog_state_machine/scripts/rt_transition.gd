class_name RTTransition

## ANY = Make transition if any condition is 'true'
## ALL = Make transition only if all conditions are 'true'
enum { ANY, ALL }

var label : String ## Atomatic filling
var to_state : StringName ## Name of the state to go if should make transition
var to_state_id : int ## Automatic filling. The index of the state once initialized
var eval_mode = ANY ## Evaluation mode

## Can be seen as 'Callable' collections with all the condition (methods) of this
## transition
signal conditions

## Add a new condition to this transition and returns the transition instance back
func add_condition(callable:Callable) -> RTTransition:
	conditions.connect(callable)
	return self

## Return 'true' if should make the transition
func evaluate_conditions() -> bool:
	match eval_mode:
		ANY:
			for c_info in conditions.get_connections():
				var callable : Callable = c_info['callable']
				if callable.call():
					return true
		ALL:
			for c_info in conditions.get_connections():
				var callable : Callable = c_info['callable']
				if !callable.call():
					return false
	return false if eval_mode == ANY else true
