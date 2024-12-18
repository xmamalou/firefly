extends Node3D

@export_category("Movement")
@export_range(1, 40)
var speed: int = 10

@onready
var camera := $center/camera as Camera3D;
@onready
var mesh := $mesh as MeshInstance3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var front_vector := (mesh.position - Vector3(
			camera.position.x,
			mesh.position.y,
			camera.position.z)).normalized()
	var perp_vector := front_vector.cross(Vector3(0, 1, 0))
	
	if Input.is_action_pressed("move_front"):
		self.position += self.speed*delta*front_vector
	if Input.is_action_pressed("move_back"):
		self.position -= self.speed*delta*front_vector
	if Input.is_action_pressed("move_left"):
		self.position -= self.speed*delta*perp_vector
	if Input.is_action_pressed("move_right"):
		self.position += self.speed*delta*perp_vector

func _input(event: InputEvent) -> void:
	if event is InputEventKey and (event as InputEventKey).is_action_pressed("quit"):
		self.get_tree().quit()
		
