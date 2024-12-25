class_name Player
extends CharacterBody3D

@export_category("Movement")
@export_range(1, 40)
var ground_speed: int = 10 ## Specifies the speed of the player when moving on the ground, in [code]meters/sec[/code]
@export_range(1, 10)
var vertical_speed: int = 2 ## specifies the speed of the player when jumping, in [code]meters/sec[/code]
@export_range(1, 10, 1)
var gravity_pull: int = 10 ## Specifies the strength of a homogenous gravitational field pulling "down", in [code]meters/sec^2[/code]

# Public variables
var spawn_point: Node3D ## Specifies a spawn point for the player, in case they are killed

# Private variables
#var _tolerance_margin: float = 0.05 ## Specifes a margin where the player is considered to move "practically" orthogonally to a collision object 

# Onready variables
@onready var camera := $center/camera as PlayerCamera
@onready var center := $center as Node3D
@onready var mesh := $mesh as MeshInstance3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	var displacement := Vector3(0, 0, 0)
	# Displacement due to ground speed and gravity
	displacement = self.velocity*delta - 0.5*self.gravity_pull*delta**2*Vector3(0, 1, 0)
	# Velocity increase (or decrease) due to gravity
	self.velocity.y -= self.gravity_pull*delta
	
	var collision: KinematicCollision3D = self.move_and_collide(displacement)
	# Player collides with something
	if collision:
		# Player cannot move downwards anymore
		# TODO: Allow player to fall if not falling *on* ground
		# TODO: Maybe add bounce as well - instead of zeroing, sets velocity to some amount
		self.velocity.y = 0
		# Player is on the ground - they can walk around and perform a jump
		if (collision.get_collider() as Node3D).is_in_group("ground"):
			# Vectors on the xz plane
			var front_vector := (center.position - Vector3(
					camera.position.x,
					center.position.y,
					camera.position.z)).normalized()
			var _normal := collision.get_normal()
			var perp_vector := front_vector.cross(collision.get_normal()).normalized()
			var plane_front_vector := perp_vector.cross(collision.get_normal()).normalized()
			# Movement on the ground
			var movement: Vector2 = Input.get_vector(
					"move_back", 
					"move_front", 
					"move_right", 
					"move_left")
			self.velocity = -self.ground_speed*( movement.x*plane_front_vector 
					+ movement.y*perp_vector )
			# Jump
			if Input.is_action_pressed("jump"):
				self.velocity.y = self.vertical_speed
		# Kill plane
		if (collision.get_collider() as Node3D).is_in_group("kill"):
			self.velocity = Vector3(0, 0, 0)
			self.position = self.spawn_point.position if self.spawn_point \
					else Vector3(0, 0, 0)
	else:
		pass

func _input(event: InputEvent) -> void:
	 # Exit the game
	if event is InputEventKey and (event as InputEventKey).is_action_pressed("quit"):
		self.get_tree().quit()
