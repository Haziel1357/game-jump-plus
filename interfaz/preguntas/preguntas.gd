extends CanvasLayer

signal resultado_marcado(es_correcto: bool)

const RUTA_DATOS := "res://escenas/niveles/preguntas/datos_preguntas.json"

@onready var popup: Control = $Popup
@onready var caja_pregunta: Panel = $Popup/CajaPregunta
@onready var label_pregunta: Label = $Popup/CajaPregunta/Pregunta
@onready var opciones: VBoxContainer = $Popup/Opciones
@onready var boton_correcto: Button = $Popup/Opciones/BotonCorrecto
@onready var boton_incorrecto: Button = $Popup/Opciones/BotonIncorrecto
@onready var banner: Label = $Banner

var _preguntas: Array = []
var _indice_siguiente: int = 0
var _turno_jugador: int = 1


func _ready() -> void:
	_cargar_preguntas()
	popup.visible = false
	banner.visible = false
	boton_correcto.pressed.connect(_marcarResultado.bind(true))
	boton_incorrecto.pressed.connect(_marcarResultado.bind(false))


func _cargar_preguntas() -> void:
	var archivo := FileAccess.open(RUTA_DATOS, FileAccess.READ)
	if archivo == null:
		push_error("No se pudo abrir: " + RUTA_DATOS)
		return
	var datos: Dictionary = JSON.parse_string(archivo.get_as_text())
	_preguntas = datos.get("preguntas", [])


## Muestra una pregunta para el jugador indicado. La pregunta aparece
## en SU mitad de pantalla; las opciones en la mitad del compañero.
## Los jugadores responden en voz real y se marca el resultado con los botones.
func mostrar_pregunta(jugador: int) -> void:
	if _preguntas.is_empty():
		push_error("No hay preguntas cargadas")
		return

	_turno_jugador = jugador
	var otro_jugador: int = 2 if jugador == 1 else 1
	var nombre_otro: String = EstadoJuego.nombre_de(otro_jugador)

	var texto: String = str(_preguntas[_indice_siguiente])
	_indice_siguiente = (_indice_siguiente + 1) % _preguntas.size()

	label_pregunta.text = texto.replace("{otro}", nombre_otro)
	_colocar_segun_turno(jugador)
	popup.visible = true
	boton_correcto.grab_focus()


## Jugador 1 = mitad izquierda, Jugador 2 = mitad derecha.
## La pregunta va en la mitad del que pregunta; las opciones en la del otro.
func _colocar_segun_turno(jugador: int) -> void:
	var tamano := get_viewport().get_visible_rect().size
	var mitad := tamano.x * 0.5

	if jugador == 1:
		caja_pregunta.position = Vector2(80, tamano.y * 0.32)
		caja_pregunta.size = Vector2(mitad - 160, 360)
		opciones.anchor_left = 1.0
		opciones.anchor_right = 1.0
		opciones.offset_left = -380
		opciones.offset_right = -80
	else:
		caja_pregunta.position = Vector2(mitad + 80, tamano.y * 0.32)
		caja_pregunta.size = Vector2(mitad - 160, 360)
		opciones.anchor_left = 0.0
		opciones.anchor_right = 0.0
		opciones.offset_left = 80
		opciones.offset_right = 380


## El resultado lo marcan los jugadores con los botones.
## Si es incorrecto, se resta vida al jugador de turno.
func _marcarResultado(es_correcto: bool) -> void:
	popup.visible = false

	if not es_correcto:
		EstadoJuego.restar_vida(_turno_jugador)

	_mostrar_banner(es_correcto)
	resultado_marcado.emit(es_correcto)


func _mostrar_banner(es_correcto: bool) -> void:
	if es_correcto:
		banner.text = "CORRECTO"
		banner.add_theme_color_override("font_color", Color(0.25, 0.85, 0.35))
	else:
		banner.text = "INCORRECTO"
		banner.add_theme_color_override("font_color", Color(0.95, 0.3, 0.3))

	banner.visible = true
	var timer := get_tree().create_timer(1.5)
	timer.timeout.connect(func() -> void: banner.visible = false)
