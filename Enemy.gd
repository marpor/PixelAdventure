# Makes an enemy move left/right (direction=1) or up/down (direction=0)

# Code adapted from https://kenney.nl/assets/pixel-line-platformer (CC0 / public domain)
extends KinematicBody2D

# Public

onready var sprite = $Sprite

export var movementSpeed = 100
export var gravityPower = 10
export var orientation = 1

# Private

var direction = 1
var gravity = 0
var dead = false

# Methods

func _physics_process(delta):
	if dead:
		gravity += gravityPower
		position.y += gravity * delta
		return

	if orientation == 0:
		if direction == 0:
			move_and_slide(Vector2(0,  movementSpeed), Vector2(0, -1))
		else:
			move_and_slide(Vector2(0, -movementSpeed), Vector2(0, -1))

		if is_on_ceiling() or is_on_floor():
			if direction == 0: direction = 1
			elif direction == 1: direction = 0

	else:
		if direction == 0:
			move_and_slide(Vector2( movementSpeed, 0), Vector2(0, -1))
			sprite.flip_h = true
		else:
			move_and_slide(Vector2(-movementSpeed, 0), Vector2(0, -1))
			sprite.flip_h = false

		if is_on_wall():
			if direction == 0: direction = 1
			elif direction == 1: direction = 0

func hit():
	if dead:
		return

	sprite.stop()
	sprite.rotation_degrees = 180

	dead = true
	gravity = -120
