extends CanvasLayer

# Duración total de la animación y cada cuánto cambia el número (en segundos).
@export var duracion_animacion: float = 2.0
@export var intervalo_numeros: float = 0.08
# Casillas que avanza el ganador de cada ronda.
@export var casillas_por_victoria: int = 1

# Referencias a los nodos hijos ($ significa "busca este hijo por su nombre").
@onready var etiqueta_numero_1: Label = $EtiquetaNumero
@onready var boton_lanzar_1: Button = $BotonLanzar
@onready var etiqueta_numero_2: Label = $EtiquetaNumero2
@onready var boton_lanzar_2: Button = $BotonLanzar2
@onready var etiqueta_resultado: Label = $EtiquetaResultado
@onready var ventana_resultado: Panel = $VentanaResultado
@onready var boton_omitir: Button = $VentanaResultado/BotonOmitir

# Guardan el número final que sacó cada jugador en la ronda actual.
var resultado_1: int = 0
var resultado_2: int = 0


func _ready() -> void:
	# Al empezar solo se ve lo del jugador 1; lo demás se oculta.
	_preparar_ronda()

	boton_lanzar_1.pressed.connect(_lanzar_jugador_1)
	boton_lanzar_2.pressed.connect(_lanzar_jugador_2)
	boton_omitir.pressed.connect(_al_pulsar_omitir)


# Deja la interfaz lista para una ronda nueva.
func _preparar_ronda() -> void:
	etiqueta_numero_1.text = "0"
	etiqueta_numero_2.text = "0"
	etiqueta_numero_2.hide()
	boton_lanzar_2.hide()
	etiqueta_resultado.hide()
	ventana_resultado.hide()
	boton_lanzar_1.show()


func _lanzar_jugador_1() -> void:
	boton_lanzar_1.hide()
	# 'await' espera a que termine la animación antes de seguir con la línea siguiente.
	resultado_1 = await _animar_dado(etiqueta_numero_1)
	# Cuando termina el jugador 1, aparece lo del jugador 2.
	etiqueta_numero_2.show()
	boton_lanzar_2.show()


func _lanzar_jugador_2() -> void:
	boton_lanzar_2.hide()
	resultado_2 = await _animar_dado(etiqueta_numero_2)
	_mostrar_ganador()


# Muestra números al azar en la etiqueta durante 'duracion_animacion' segundos
# y devuelve el número final. Usa 'await', así que es una función que "espera".
func _animar_dado(etiqueta: Label) -> int:
	var tiempo: float = 0.0
	while tiempo < duracion_animacion:
		etiqueta.text = str(randi_range(1, 6))
		# Esperamos un ratito sin congelar el juego.
		await get_tree().create_timer(intervalo_numeros).timeout
		tiempo += intervalo_numeros

	var numero_final: int = randi_range(1, 6)
	etiqueta.text = str(numero_final)
	return numero_final


# Compara los dos resultados, anota el avance del ganador y muestra la ventana.
func _mostrar_ganador() -> void:
	if resultado_1 > resultado_2:
		etiqueta_resultado.text = "¡Gana el jugador 1!"
		EstadoJuego.avanzar(1, casillas_por_victoria)
	elif resultado_2 > resultado_1:
		etiqueta_resultado.text = "¡Gana el jugador 2!"
		EstadoJuego.avanzar(2, casillas_por_victoria)
	else:
		# En empate nadie avanza.
		etiqueta_resultado.text = "¡Empate!"

	# Mostramos las casillas de cada jugador para comprobar que se guardan.
	etiqueta_resultado.text += "\nCasillas J1: %d | J2: %d" % [
		EstadoJuego.obtener_casillas(1),
		EstadoJuego.obtener_casillas(2),
	]
	etiqueta_resultado.show()
	ventana_resultado.show()


# Al pulsar "Omitir" se cierra la ventana y empieza una ronda nueva.
func _al_pulsar_omitir() -> void:
	_preparar_ronda()
