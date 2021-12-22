extends Spatial


export var ANIMATE_APPEARANCE := true
export var LIFT := 0.002
export var PARACHUTE := 0.1
export var SIDEDRAG := 0.02
export var SIDE_BALANCING := 0.004
export var THRUST := 5

onready var p := get_parent() as RigidBody
var tw := Tween.new()


# you can call this func to animate disappearance
func dissolve():
	scale(Vector3.ZERO, 0.2)
	yield(tw, "tween_all_completed")
	queue_free()


func _ready():
	add_child(tw)
	if ANIMATE_APPEARANCE:
		scale = Vector3.ZERO
		scale(Vector3.ONE)


func _physics_process(_delta):
	var b := p.transform.basis
	
	# finding local velocity
	var vel := b.xform_inv(p.linear_velocity)
	
	# parachuting
	var f := -Vector3.UP * PARACHUTE * sign(vel.y) * vel.y * vel.y
	
	# sidedrag
	f += -Vector3.RIGHT * SIDEDRAG * sign(vel.x) * vel.x * vel.x
	
	# lift
	f += Vector3.UP * LIFT * vel.z * vel.z
	
	p.apply_central_impulse(b * f)
	
	p.apply_torque_impulse(b * -Vector3.FORWARD * SIDE_BALANCING * vel.x)


func scale(s : Vector3, time := 0.3):
	tw.interpolate_property(self, "scale", scale, s, time, Tween.TRANS_SINE, Tween.EASE_OUT)
	tw.start()
