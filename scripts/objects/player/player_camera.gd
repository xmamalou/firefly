extends Camera3D
class_name PlayerCamera

@export_range(0.01, 0.09, 0.001)
var motion_subdivide := 0.03 ## Subdivision amount of the relative motion of the mouse.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var change := (event as InputEventMouseMotion).relative
		var d_azimuth := self.motion_subdivide*change.x
		var d_alt := self.motion_subdivide*change.y
		self.rotate_cam(
				Vector2(d_azimuth, d_alt))

## [font=res://assets/fonts/inter.ttf]
## Rotate the camera according to an azimuth and altitude angle
## [br]
## [b]PARAMETERS[/b][br]
## - [param d_angle]: a 2D vector, where [param x] is the azimuth angle and [param y] the altitude angle
## [/font]
func rotate_cam(d_angle: Vector2) -> void:
	#var cam_plane_angle := atan(self.position.x/self.position.z)
	# Rotation
	self.rotation.y += d_angle.x
	#self.rotation.x += cos(cam_plane_angle)*d_angle.y
	#self.rotation.z += sin(cam_plane_angle)*d_angle.y
	# Position
	var plane_vec := Vector3(self.position.x, 0, self.position.z).rotated(
			Vector3(0, self.position.y, 0).normalized(), d_angle.x)
	self.position = Vector3(plane_vec.x, self.position.y, plane_vec.z)
