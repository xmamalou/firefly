extends Node3D

@onready var player := $player as Player
@onready var spawn_point := $spawn_point as Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.spawn_point = spawn_point


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
