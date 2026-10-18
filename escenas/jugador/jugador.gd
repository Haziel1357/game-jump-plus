extends CharacterBody3D

# Compartido con la selección de jugador para que el color sea el mismo.
const TintePersonaje := preload("res://scripts/globales/tinte_personaje.gd")

@export var camino_node: Node3D
@export var duracion_salto: float = 0.6
@export var altura_salto: float = 1.2
@export var desfase_altura: float = 0.5
@export var habilita_tecla_prueba: bool = true
@export var tecla_salto: StringName = &"ui_accept"
# Número de jugador (1 o 2) cuyo color de selección debe pintar este modelo.
# 0 = no pintar nada. Se asigna en el Inspector de la escena del nivel.
@export var numero_jugador: int = 0

# Nombres exactos de las animaciones configurables desde el Inspector
@export var anim_idle: StringName = &"Idle_Respiracion"
@export var anim_salto_360: StringName = &"Salto_360"
@export var anim_salto: StringName = &"Salto"
@export var anim_victoria: StringName = &"salto_Doble_giro" # O "Salto_720" para Jugador 2
@export var anim_negacion: StringName = &"Negacion"

# Malla 3D visual (Robot / ROBOT!_3) para rotar sin desplazar la raíz
@export var nodo_visual: Node3D

# Cámara dinámica de Haziel (la cámara se acerca al jugador mientras actúa).
# Está APAGADA: el juego usa las cámaras por personaje de Juan (las cambia CicloRonda).
@export var camara_dinamica: bool = false

# Configuración de Cámara Dinámica
@export var camera_node: Camera3D
@export var velocidad_camara: float = 4.0
@export var distancia_cerca: Vector3 = Vector3(0, 1.8, 2.5) # Enfoque de cerca para el personaje

# Control de estado de cámara
var camara_activa: bool = false

var _puntos_path: PackedVector3Array = []
var _indice_siguiente: int = 0
var _saltando: bool = false
var _anim_player: AnimationPlayer = null
# Posición con la que el nivel colocó el modelo (cada robot tiene su propio desfase).
var _posicion_visual_base: Vector3 = Vector3.ZERO

# Posición y rotación original de la cámara panorámica del inicio
static var _pos_camara_inicial: Vector3
static var _rot_camara_inicial: Vector3
static var _camara_inicial_guardada: bool = false


func _ready() -> void:
	_anim_player = _buscar_animation_player(self)
	
	if camino_node != null:
		_puntos_path.clear()
		
		if camino_node is Path3D and (camino_node as Path3D).curve != null:
			var curva := (camino_node as Path3D).curve
			var transform_global := camino_node.global_transform
			for i in range(curva.point_count):
				_puntos_path.append(transform_global * curva.get_point_position(i))
		else:
			for hijo in camino_node.get_children():
				if hijo is Node3D:
					_puntos_path.append(hijo.global_position)

		if _puntos_path.size() > 0:
			global_position = _puntos_path[0] + Vector3(0, desfase_altura, 0)
			_indice_siguiente = 1

	if camara_dinamica and camera_node == null:
		camera_node = get_viewport().get_camera_3d()

	# Guardar la transformación panorámica inicial de la cámara principal
	if camara_dinamica and camera_node != null and not _camara_inicial_guardada:
		_pos_camara_inicial = camera_node.global_position
		_rot_camara_inicial = camera_node.global_rotation
		_camara_inicial_guardada = true

	_reproducir_animacion(anim_idle)


func _process(delta: float) -> void:
	# Si este jugador tiene el foco de la cámara durante su movimiento, la cámara se acerca a él
	if camara_dinamica and camara_activa and camera_node != null:
		var pos_deseada := global_position + (global_transform.basis * distancia_cerca)
		camera_node.global_position = camera_node.global_position.lerp(pos_deseada, delta * velocidad_camara)

	# Coloreado temporal dentro de la isla (ver tinte_personaje.gd).
	_pintar_modelo()


## Pinta el modelo de este personaje con el color elegido en la selección.
func _pintar_modelo() -> void:
	if numero_jugador <= 0:
		return
	TintePersonaje.aplicar(self, EstadoJuego.color_de(numero_jugador))


func _unhandled_input(event: InputEvent) -> void:
	if not habilita_tecla_prueba or _saltando:
		return

	if event.is_action_pressed(tecla_salto):
		avanzar_siguiente_punto()


# Llamar desde la UI al responder CORRECTAMENTE
func responder_correcto() -> void:
	camara_activa = camara_dinamica
	await avanzar_siguiente_punto()
	camara_activa = false


# Llamar desde la UI al responder INCORRECTAMENTE
func responder_incorrecto() -> void:
	if _saltando:
		return
		
	_saltando = true
	camara_activa = camara_dinamica
	_resetear_posicion_visual()

	if _anim_player != null and _anim_player.has_animation(anim_negacion):
		_reproducir_animacion(anim_negacion)
		await _anim_player.animation_finished
	else:
		push_warning("No se encontró la animación: %s" % anim_negacion)
		await get_tree().create_timer(1.0).timeout
		
	_resetear_posicion_visual()
	_saltando = false
	camara_activa = false
	_reproducir_animacion(anim_idle)


func avanzar_siguiente_punto() -> void:
	if _saltando or _puntos_path.size() < 2 or _indice_siguiente >= _puntos_path.size():
		return

	var destino := _puntos_path[_indice_siguiente] + Vector3(0, desfase_altura, 0)
	var es_ultimo_punto := (_indice_siguiente == _puntos_path.size() - 1)
	_indice_siguiente += 1
	
	await _realizar_secuencia_salto(destino, es_ultimo_punto)


func _realizar_secuencia_salto(destino: Vector3, es_victoria: bool) -> void:
	_saltando = true
	var origen := global_position

	# 1. Orientar la malla hacia el destino
	_resetear_posicion_visual()
	var dir := (destino - origen)
	dir.y = 0.0
	if dir.length_squared() > 0.001:
		var objetivo_rotacion := global_position + dir
		if nodo_visual != null:
			nodo_visual.look_at(objetivo_rotacion, Vector3.UP)

	# 2. Celebración acierto (Salto 360) enfocado de cerca
	if _anim_player != null and _anim_player.has_animation(anim_salto_360):
		_reproducir_animacion(anim_salto_360)
		await _anim_player.animation_finished

	_resetear_posicion_visual()

	# 3. Salto parabólico a la casilla
	_reproducir_animacion(anim_salto)
	var tiempo := 0.0

	while tiempo < duracion_salto:
		tiempo += get_process_delta_time()
		var t := clampf(tiempo / duracion_salto, 0.0, 1.0)
		
		var altura_arco := 4.0 * altura_salto * t * (1.0 - t)
		var pos_base := origen.lerp(destino, t)
		global_position = pos_base + Vector3(0, altura_arco, 0)

		await get_tree().process_frame

	global_position = destino
	_resetear_posicion_visual()

	# 4. Victoria si llega al final
	if es_victoria:
		if _anim_player != null and _anim_player.has_animation(anim_victoria):
			_reproducir_animacion(anim_victoria)
			await _anim_player.animation_finished
			_resetear_posicion_visual()

	_saltando = false
	_reproducir_animacion(anim_idle)


# Función para regresar la cámara a la vista panorámica inicial cuando termina la ronda
func restablecer_camara_principal() -> void:
	camara_activa = false
	if camara_dinamica and camera_node != null and _camara_inicial_guardada:
		var tween := create_tween().set_parallel(true)
		tween.tween_property(camera_node, "global_position", _pos_camara_inicial, 1.2).set_trans(Tween.TRANS_SINE)
		tween.tween_property(camera_node, "global_rotation", _rot_camara_inicial, 1.2).set_trans(Tween.TRANS_SINE)


func _resetear_posicion_visual() -> void:
	if nodo_visual != null:
		nodo_visual.position = _posicion_visual_base


# Asigna el modelo 3D que usa este jugador (por ejemplo, el personaje elegido en la
# selección) y vuelve a buscar su AnimationPlayer. Lo llama CicloRonda al empezar.
func usar_modelo(modelo: Node3D) -> void:
	nodo_visual = modelo
	_posicion_visual_base = modelo.position
	_anim_player = _buscar_animation_player(modelo)
	_reproducir_animacion(anim_idle)


func _reproducir_animacion(nombre_anim: StringName) -> void:
	if _anim_player == null:
		_anim_player = _buscar_animation_player(self)

	if _anim_player != null and _anim_player.has_animation(nombre_anim):
		var anim := _anim_player.get_animation(nombre_anim)
		if anim != null:
			if nombre_anim == anim_idle:
				anim.loop_mode = Animation.LOOP_LINEAR
			else:
				anim.loop_mode = Animation.LOOP_NONE

		_anim_player.play(nombre_anim)


func _buscar_animation_player(nodo: Node) -> AnimationPlayer:
	if nodo is AnimationPlayer:
		return nodo as AnimationPlayer
	
	for hijo in nodo.get_children():
		var res := _buscar_animation_player(hijo)
		if res != null:
			return res
			
	return null
