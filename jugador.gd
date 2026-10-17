extends CharacterBody3D

# @export hace que estas variables aparezcan en el Inspector,
# así puedes ajustarlas sin tocar el código.
@export var velocidad: float = 5.0
@export var fuerza_salto: float = 4.5

# Tomamos la gravedad configurada en el proyecto (9.8 por defecto).
var gravedad: float = ProjectSettings.get_setting("physics/3d/default_gravity")


# _physics_process se ejecuta 60 veces por segundo, sincronizado con la física.
# 'delta' es el tiempo transcurrido desde el último fotograma.
func _physics_process(delta: float) -> void:
	# 1. Gravedad: si estamos en el aire, caemos.
	if not is_on_floor():
		velocity.y -= gravedad * delta

	# 2. Salto con la barra espaciadora (acción "ui_accept").
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = fuerza_salto

	# 3. Leemos las flechas. get_vector devuelve un Vector2 entre -1 y 1:
	#    x = izquierda/derecha, y = arriba/abajo.
	var entrada: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	# 4. Convertimos ese Vector2 a 3D. En Godot, el eje Z es adelante/atrás
	#    (Z negativo es "adelante"), y el eje Y es la altura, que no tocamos aquí.
	var direccion: Vector3 = Vector3(entrada.x, 0, entrada.y).normalized()

	# 5. Si hay dirección, nos movemos; si no, frenamos poco a poco.
	if direccion != Vector3.ZERO:
		velocity.x = direccion.x * velocidad
		velocity.z = direccion.z * velocidad
	else:
		velocity.x = move_toward(velocity.x, 0, velocidad)
		velocity.z = move_toward(velocity.z, 0, velocidad)

	# 6. move_and_slide aplica 'velocity', detecta colisiones
	#    y hace que el personaje se deslice por paredes en vez de atascarse.
	move_and_slide()
