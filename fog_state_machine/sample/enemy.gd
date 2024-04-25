extends RigidBody3D
class_name EnemySample

@export var life_points : int = 5

var dead : bool
var total_life_points : int
var respawn_time : float
var timer : float


func _ready():
	total_life_points = life_points

func _process(delta):
	if dead:
		timer += delta
		if timer >= respawn_time:
			respawn()


func damage(by:int):
	print("Enemy: OUCH!!")
	total_life_points-=by
	if total_life_points <= 0:
		die()
	else:
		create_damage_effect()

func create_damage_effect():
	scale = Vector3.ONE * 0.7
	var tween = get_tree().create_tween()
	tween.tween_property(self, 'scale', Vector3.ONE, 0.5).set_trans(Tween.TRANS_BOUNCE)

func die():
	print("OK, I'm out...")
	dead = true
	visible = false
	respawn_time = randf_range(0.1, 2.0)
	timer = 0.0

func respawn():
	position = random_position_inside_radius(10.0)
	visible = true
	dead = false
	total_life_points = life_points

func random_position_inside_radius(radius:float):
	var x = randf() * 2 - 1
	var y = 0.0
	var z = randf() * 2 - 1
	
	return Vector3(x, y, z).normalized() * radius
