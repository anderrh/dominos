extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var camera=$Camera3D
@onready var raycast=$Camera3D/RayCast3D
var leftbutton:bool
var rightbutton:bool
var hover_object:RigidBody3D
const highlight=preload("res://highlight.tres")
const domino=preload("res://domino.tscn")



func _physics_process(delta):
	if position.y<-100:
		respawn()
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	for col_idx in get_slide_collision_count():
		var col := get_slide_collision(col_idx)
		if col.get_collider() is RigidBody3D:
			col.get_collider().apply_central_impulse(-col.get_normal() * 0.1)
			col.get_collider().apply_impulse(-col.get_normal() * 0.01, col.get_position())
#leftclick push
	var hit=raycast.get_collider()
	if hit is RigidBody3D:
		if hit != hover_object:
			if hover_object !=null:
				hover_object.get_node("MeshInstance3D").material_overlay=null
			hover_object = hit
			hit.get_node("MeshInstance3D").material_overlay=highlight
	else:
		if hover_object !=null:
				hover_object.get_node("MeshInstance3D").material_overlay=null
		hover_object = null
	if rightbutton:
		rightbutton=false
		place_domino(raycast.get_collision_point())
	if leftbutton:
		leftbutton=false
		if hit is RigidBody3D:
			hit.apply_impulse(raycast.get_collision_normal()*-0.5,Vector3(0,0.24,0))




# Respawn
func respawn():
	position=Vector3(0,1.5,0)
	rotation_degrees=Vector3(0,0,0)
	camera.rotation_degrees=Vector3(0,0,0)


#mouse movement
func _input(event):
	if event is InputEventMouseMotion:
		if Input.mouse_mode==Input.MOUSE_MODE_CAPTURED:
			rotate_y(event.relative.x/-100.00000)
			camera.rotate_x(event.relative.y/-100.00000)
			camera.rotation_degrees.x=clampf(camera.rotation_degrees.x,-90,90)
	if event is InputEventMouseButton:
		if event.button_index==1:
			leftbutton=true
		if event.button_index==2:
			rightbutton=true
		Input.mouse_mode=Input.MOUSE_MODE_CAPTURED
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode=Input.MOUSE_MODE_VISIBLE



func place_domino(pos):
	var clone_domino=domino.instantiate()
	clone_domino.position
	get_parent().add_child(clone_domino)
	
	


