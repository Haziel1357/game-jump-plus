extends CharacterBody3D

# Asignaremos "Camino plataformas jugador 1" o "Camino plataformas jugador 2" desde el Inspector
@export var camino_node: Node3D

# Parámetros del salto
@export var duracion_salto: float = 0.6
@export var altura_salto_extra: float = 1.2
@export var desfase_altura: float = 0.5 

# Control de prueba por teclado
@export var habilitar_tecla_prueba: bool = false
@export var tecla_salto: String = "ui_accept"

var puntos: Array = []
var indice_actual: int = 0
var esta_saltando: bool = false

func _ready() -> void:
	if camino_node:
		# Extrae la posición global de los Marker3D contenidos en el camino
		for punto in camino_node.get_children():
			if punto is Node3D:
				var pos_ajustada: Vector3 = punto.global_position
				pos_ajustada.y += desfase_altura
				puntos.append(pos_ajustada)
		
		# Sitúa al personaje en la casilla inicial de su ruta
		if puntos.size() > 0:
			global_position = puntos[0]

func _unhandled_input(event: InputEvent) -> void:
	if habilitar_tecla_prueba and event.is_action_pressed(tecla_salto) and not esta_saltando:
		saltar_a_siguiente_plataforma()

# Método invocado por la UI cuando la respuesta es correcta
func saltar_a_siguiente_plataforma() -> void:
	if indice_actual + 1 < puntos.size():
		indice_actual += 1
		var destino: Vector3 = puntos[indice_actual]
		esta_saltando = true
		
		# Movimiento horizontal (X, Z)
		var tween_x = create_tween()
		tween_x.tween_property(self, "global_position:x", destino.x, duracion_salto)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		
		var tween_z = create_tween()
		tween_z.tween_property(self, "global_position:z", destino.z, duracion_salto)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			
		# Elevación y caída (Y)
		var altura_maxima: float = max(global_position.y, destino.y) + altura_salto_extra
		var tiempo_mitad: float = duracion_salto / 2.0
		
		var tween_y = create_tween()
		tween_y.tween_property(self, "global_position:y", altura_maxima, tiempo_mitad)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween_y.tween_property(self, "global_position:y", destino.y, tiempo_mitad)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
			
		tween_y.finished.connect(func(): esta_saltando = false)
