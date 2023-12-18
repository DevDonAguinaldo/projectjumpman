extends CharacterBody3D

const SPEED = 10.0
const JUMP_VELOCITY = 4.0

@export var sens = 0.5

@onready var animation_player: AnimationPlayer = $Body/AnimationPlayer
@onready var camera_origin: Node3D = $CameraOrigin

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sens))
		camera_origin.rotate_x(deg_to_rad(-event.relative.y * sens))
		camera_origin.rotation.x = clamp(camera_origin.rotation.x, deg_to_rad(-90), deg_to_rad(0))

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if is_on_floor():
		if direction:
			animation_player.play("walking")
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
	else:
		var air_control_factor := 0.05
		if direction:
			velocity.x = move_toward(velocity.x, direction.x * SPEED, SPEED * air_control_factor)
			velocity.z = move_toward(velocity.z, direction.z * SPEED, SPEED * air_control_factor)

	move_and_slide()
