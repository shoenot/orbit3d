extends Node3D

@onready var simulation = $GravitySim
@onready var camera = $Camera

var bodies = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	create_coordinate_planes(2000.0)
	simulation.set_big_g(100.0)
	register_body(Vector3(0, 0, 0), Vector3(0, 0, 0), 50, 100000)
	register_body(Vector3(300, 0, 0), Vector3(0, 230, 30), 20, 100)
	camera.position = Vector3(0, 1000, 0)
	camera.look_at(Vector3.ZERO)
	
func register_body(position: Vector3, velocity: Vector3, radius, mass):
	var body = create_sphere(position, radius, Color.WHITE)
	var id = simulation.add_body(position, velocity, mass, radius)
	body.position = position
	bodies.append({
		"node": body,
		"id": id,
	})

func create_sphere(pos: Vector3, radius: float, color: Color) -> MeshInstance3D:
	var sphere = MeshInstance3D.new()
	var mesh = SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0  
	sphere.mesh = mesh
	
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sphere.material_override = material
	
	sphere.position = pos
	add_child(sphere)
	return sphere

func create_coordinate_planes(size := 2000.0) -> void:
	create_plane(
		"XY Plane",
		Vector2(size, size),
		Vector3(deg_to_rad(90), 0, 0),
		Color(0.2, 0.4, 1.0, 0.12)
	)

	create_plane(
		"XZ Plane",
		Vector2(size, size),
		Vector3.ZERO,
		Color(0.2, 1.0, 0.4, 0.12)
	)

	create_plane(
		"YZ Plane",
		Vector2(size, size),
		Vector3(0, 0, deg_to_rad(90)),
		Color(1.0, 0.3, 0.3, 0.12)
	)


func create_plane(
	plane_name: String,
	size: Vector2,
	rotation: Vector3,
	color: Color
) -> void:
	var instance := MeshInstance3D.new()
	instance.name = plane_name

	var mesh := PlaneMesh.new()
	mesh.size = size

	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.cull_mode = BaseMaterial3D.CULL_DISABLED

	mesh.material = material
	instance.mesh = mesh

	instance.rotation = rotation

	add_child(instance)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	simulation.step(delta)
	for body in bodies: 
		body.node.position = simulation.get_body_position(body.id)
