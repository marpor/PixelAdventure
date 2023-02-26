# A simple player controller. Moves with left/right/up actions.

# Code adapted from https://kenney.nl/assets/pixel-line-platformer (CC0 / public domain)
extends KinematicBody2D

# Public

onready var sprite = $Sprite

export var movementSpeed = 200
export var gravityPower = 20
export var jumpPower = 30

export var slideOnCeiling = false

export (PackedScene) var projectile

# Private

var velocity = Vector2(0, 0)
var movementVelocity = Vector2(0, 0)
var gravity = 0

var doubleJump = true
var previouslyFloored = false
var previouslyDestroyed = false

var initialPosition

# Methods

func _ready():
	initialPosition = position

func _physics_process(delta):
	applyControls()
	applyGravity()
	applyAnimation()

	# Out of bounds

	if position.y > 4800 or Input.is_action_just_pressed("reset"):
		position = initialPosition

	# Apply movement

	velocity = velocity.linear_interpolate(movementVelocity, delta * 8)
	move_and_slide(velocity + Vector2(0, gravity), Vector2(0, -1))

	# Effects

	sprite.scale = sprite.scale.linear_interpolate(Vector2(1, 1), delta * 8)

	if is_on_floor() and !previouslyFloored:
		sprite.scale = Vector2(1.25, 0.75)

	previouslyFloored = is_on_floor()

# Player controls

func applyControls():
	movementVelocity = Vector2(0, 0)

	if Input.is_action_pressed("left"):

		movementVelocity.x = -movementSpeed
		sprite.flip_h = true

	elif Input.is_action_pressed("right"):

		movementVelocity.x = movementSpeed
		sprite.flip_h = false

	if Input.is_action_just_pressed("jump"):

		if is_on_floor():
			jump(1)
			doubleJump = true
		elif doubleJump:
			jump(1)
			doubleJump = false

	if Input.is_action_just_pressed("shoot"):
		shoot()

# Apply gravity and jumping

func applyGravity():
	gravity += gravityPower

	if gravity > 0 and is_on_floor():
		gravity = 10
		previouslyDestroyed = false

	if slideOnCeiling:
		if is_on_ceiling():
			gravity = 0

func jump(multiplier):
	gravity = -jumpPower * multiplier * 10
	sprite.scale = Vector2(0.5, 1.5)

func shoot():
	if not projectile:
		return # No projectile = no shooting!

	var _projectile = projectile.instance()
	get_tree().get_root().add_child(_projectile)

	if !sprite.flip_h:
		_projectile.direction = 1
		_projectile.position = position + Vector2( 8, 2) # Projectile spawn position
		movementVelocity.x = -movementSpeed * 2 # Knockback
	else:
		_projectile.position = position + Vector2(-8, 2) # Projectile spawn position
		movementVelocity.x = movementSpeed * 2 # Knockback

	sprite.scale = Vector2(0.75, 1.25)

# Set animations

func applyAnimation():
	if is_on_floor():
		if abs(velocity.x) > 60:
			sprite.play("Run")
		else:
			sprite.play("Idle")
	else:
		if not doubleJump:
			sprite.play("Double Jump")
		else:
			sprite.play("Jump")
