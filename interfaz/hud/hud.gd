extends CanvasLayer

@onready var label_vidas_1: Label = $Panel/VidaJugador1/TextoVidas
@onready var label_vidas_2: Label = $Panel/VidaJugador2/TextoVidas
@onready var boton_fallo_1: Button = $Panel/Prueba/BotonFallo1
@onready var boton_fallo_2: Button = $Panel/Prueba/BotonFallo2
@onready var boton_pregunta: Button = $Panel/Prueba/BotonPregunta

var _turno: int = 1


func _ready() -> void:
	EstadoJuego.vidas_cambiadas.connect(_on_vidas_cambiadas)
	boton_fallo_1.pressed.connect(EstadoJuego.restar_vida.bind(1))
	boton_fallo_2.pressed.connect(EstadoJuego.restar_vida.bind(2))
	boton_pregunta.pressed.connect(_pedir_pregunta)
	_refrescar_todo()


func _pedir_pregunta() -> void:
	var preguntas := get_node_or_null("/root/MundoPruebas/Preguntas")
	if preguntas:
		preguntas.mostrar_pregunta(_turno)
		_turno = 2 if _turno == 1 else 1


func _refrescar_todo() -> void:
	label_vidas_1.text = _texto_vidas(1)
	label_vidas_2.text = _texto_vidas(2)


func _texto_vidas(jugador: int) -> String:
	var nombre: String = EstadoJuego.nombre_de(jugador)
	var vidas: int = EstadoJuego.vidas_de(jugador)
	return "%s  %s (%d)" % [nombre, "♥".repeat(vidas), vidas]


func _on_vidas_cambiadas(jugador: int, _vidas: int) -> void:
	if jugador == 1:
		label_vidas_1.text = _texto_vidas(1)
	else:
		label_vidas_2.text = _texto_vidas(2)
