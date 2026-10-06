extends Camera3D

@export var target := Vector3.ZERO

@export var distance := 1000.0
@export var min_distance := 50.0
@export var max_distance := 10000.0

@export var rotate_sensitivity := 0.005
@export var pan_sensitivity := 1.0
@export var zoom_factor := 1.15

var yaw := 0.0
var pitch := 0.0

var rotating := false
var panning := false


func _ready() -> void:
	current = true
	update_camera()


func _unhandled_input(event) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			rotating = event.pressed

		elif event.button_index == MOUSE_BUTTON_MIDDLE:
			panning = event.pressed

		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			distance /= zoom_factor
			distance = max(distance, min_distance)
			update_camera()

		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			distance *= zoom_factor
			distance = min(distance, max_distance)
			update_camera()

	elif event is InputEventMouseMotion:
		if rotating:
			yaw -= event.relative.x * rotate_sensitivity
			pitch -= event.relative.y * rotate_sensitivity

			pitch = clamp(
				pitch,
				deg_to_rad(-89.0),
				deg_to_rad(89.0)
			)

			update_camera()

		elif panning:
			var right := global_transform.basis.x
			var up := global_transform.basis.y

			var scale := distance * 0.001 * pan_sensitivity

			target -= right * event.relative.x * scale
			target += up * event.relative.y * scale

			update_camera()


func update_camera() -> void:
	var offset := Vector3(
		cos(pitch) * sin(yaw),
		sin(pitch),
		cos(pitch) * cos(yaw)
	) * distance

	global_position = target + offset
	look_at(target, Vector3.UP)
