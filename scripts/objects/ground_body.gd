class_name GroundBody
extends StaticBody3D

@export_range(0, 100, 1) var bounce: int = 0 ## How much bounce the ground has; is simply a multiplier of the colliding object's velocity
@export_range(0, 100, 1, "suffix:%") var dissipation: float = 0 ## How much of the energy gets absorbed by the object
	
