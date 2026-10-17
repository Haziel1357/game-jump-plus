extends CanvasLayer

signal pregunta_contestada(es_correcta: bool)

const RUTA_DATOS := "res://escenas/niveles/preguntas/datos_preguntas.json"

@onready var popup: Control = $Popup
@onready var label_pregunta: Label = $Popup/Centro/Caja/Pregunta
@onready var boton_correcto: Button = $Popup/Opciones/BotonCorrecto
@onready var boton_incorrecto: Button = $Popup/Opciones/BotonIncorrecto
@onready var banner: Label = $Banner

var _preguntas: Array = []
var _indice_siguiente: int = 0
var _respuesta_actual: bool = false
var _turno_jugador: int = 1


func _ready() -> void:
	_cargar_preguntas()
	popup.visible = false
	banner.visible = false
	boton_correcto.pressed.connect(_responder.bind(true))
	boton_incorrecto.pressed.connect(_responder.bind(false))


func _cargar_preguntas() -> void:
	var archivo := FileAccess.open(RUTA_DATOS, FileAccess.READ)
	if archivo == null:
		push_error("No se pudo abrir: " + RUTA_DATOS)
		return
	var datos: Dictionary = JSON.parse_string(archivo.get_as_text())
	_preguntas = datos.get("preguntas", [])


## Muestra una pregunta para el jugador indicado. {otro} se sustituye
## por el nombre del compañero de partida.
func mostrar_pregunta(jugador: int) -> void:
	if _preguntas.is_empty():
		push_error("No hay preguntas cargadas")
		return

	_turno_jugador = jugador
	var otro_jugador: int = 2 if jugador == 1 else 1
	var nombre_otro: String = EstadoJuego.nombre_de(otro_jugador)

	var pregunta: Dictionary = _preguntas[_indice_siguiente]
	_indice_siguiente = (_indice_siguiente + 1) % _preguntas.size()

	_respuesta_actual = bool(pregunta["respuesta_correcta"])
	label_pregunta.text = str(pregunta["texto"]).replace("{otro}", nombre_otro)
	popup.visible = true
	boton_correcto.grab_focus()


func _responder(elegido_correcto: bool) -> void:
	popup.visible = false
	var es_correcta: bool = elegido_correcto == _respuesta_actual

	if not es_correcta:
		EstadoJuego.restar_vida(_turno_jugador)

	_mostrar_banner(es_correcta)
	pregunta_contestada.emit(es_correcta)


func _mostrar_banner(es_correcta: bool) -> void:
	if es_correcta:
		banner.text = "CORRECTO"
		banner.add_theme_color_override("font_color", Color(0.25, 0.85, 0.35))
	else:
		banner.text = "INCORRECTO"
		banner.add_theme_color_override("font_color", Color(0.95, 0.3, 0.3))

	banner.visible = true
	var timer := get_tree().create_timer(1.5)
	timer.timeout.connect(func() -> void: banner.visible = false)
