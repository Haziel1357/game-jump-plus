extends CharacterBody3D

@export var camino_node: Node3D
@export var duracion_salto: float = 0.6
@export var altura_salto: float = 1.2
@export var desfase_altura: float = 0.5
@export var habilita_tecla_prueba: bool = true
@export var tecla_salto: StringName = &"ui_accept"

var _puntos_path: PackedVector3Array = []
var _indice_siguiente: int = 0
var _saltando: bool = false


func _ready() -> void:
	if camino_node != null:
		_puntos_path.clear()
		
		# Si el nodo asignado es un Path3D con curva
		if camino_node is Path3D and (camino_node as Path3D).curve != null:
			var curva := (camino_node as Path3D).curve
			var transform_global := camino_node.global_transform
			for i in range(curva.point_count):
				var pos_local := curva.get_point_position(i)
				_puntos_path.append(transform_global * pos_local)
		else:
			# Si es un Node3D con marcadores/hijos
			for hijo in camino_node.get_children():
				if hijo is Node3D:
					_puntos_path.append(hijo.global_position)

		if _puntos_path.size() > 0:
			global_position = _puntos_path[0] + Vector3(0, desfase_altura, 0)
			_indice_siguiente = 1
	else:
		push_warning("Asigna un nodo de camino en el Inspector para este jugador.")


func _unhandled_input(event: InputEvent) -> void:
	if not habilita_tecla_prueba or _saltando:
		return

	if event.is_action_pressed(tecla_salto):
		avanzar_siguiente_punto()


func avanzar_siguiente_punto() -> void:
	if _saltando or _puntos_path.size() < 2:
		return

	if _indice_siguiente >= _puntos_path.size():
		return

	var destino := _puntos_path[_indice_siguiente] + Vector3(0, desfase_altura, 0)
	_indice_siguiente += 1
	_realizar_salto(destino)


func _realizar_salto(destino: Vector3) -> void:
	_saltando = true
	var origen := global_position
	var tiempo := 0.0

	while tiempo < duracion_salto:
		tiempo += get_process_delta_time()
		var t := clampf(tiempo / duracion_salto, 0.0, 1.0)
		
		# Parábola de salto
		var altura_arco := 4.0 * altura_salto * t * (1.0 - t)
		var pos_base := origen.lerp(destino, t)
		global_position = pos_base + Vector3(0, altura_arco, 0)

		await get_tree().process_frame

	global_position = destino
	_saltando = false
