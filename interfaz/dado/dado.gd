class_name Dado
extends CanvasLayer

# Se emite al pulsar "Omitir" cuando hay un ganador (1 o 2).
# En caso de empate no se emite: simplemente se repiten los dados.
signal ronda_terminada(ganador: int)

# Duración total de la animación y cada cuánto cambia el número (en segundos).
@export var duracion_animacion: float = 2.0
@export var intervalo_numeros: float = 0.08

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
# Jugador que ganó los dados (0 = empate).
var ganador: int = 0


func _ready() -> void:
	boton_lanzar_1.pressed.connect(_lanzar_jugador_1)
	boton_lanzar_2.pressed.connect(_lanzar_jugador_2)
	boton_omitir.pressed.connect(_al_pulsar_omitir)
	iniciar_ronda()


# Muestra el dado y lo deja listo para que el jugador 1 lance.
# Lo llama quien coordina los turnos cuando hay que volver a tirar.
func iniciar_ronda() -> void:
	visible = true
	etiqueta_numero_1.show()
	etiqueta_numero_1.text = "0"
	etiqueta_numero_2.text = "0"
	etiqueta_numero_2.hide()
	boton_lanzar_2.hide()
	etiqueta_resultado.hide()
	ventana_resultado.hide()
	boton_lanzar_1.show()


# Muestra un mensaje final (por ejemplo, quién ganó la partida) y oculta el resto.
func mostrar_fin(texto: String) -> void:
	visible = true
	etiqueta_numero_1.hide()
	etiqueta_numero_2.hide()
	boton_lanzar_1.hide()
	boton_lanzar_2.hide()
	ventana_resultado.hide()
	etiqueta_resultado.text = texto
	etiqueta_resultado.show()


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


# Compara los dos resultados, decide quién empieza y muestra la ventana.
func _mostrar_ganador() -> void:
	if resultado_1 > resultado_2:
		ganador = 1
		etiqueta_resultado.text = "¡Empieza el jugador 1!"
	elif resultado_2 > resultado_1:
		ganador = 2
		etiqueta_resultado.text = "¡Empieza el jugador 2!"
	else:
		ganador = 0
		etiqueta_resultado.text = "¡Empate! Se repite el dado"
	etiqueta_resultado.show()
	ventana_resultado.show()


# Al pulsar "Omitir": si hubo ganador, se oculta el dado y se avisa a quien
# coordina los turnos; si fue empate, se vuelve a tirar.
func _al_pulsar_omitir() -> void:
	if ganador == 0:
		iniciar_ronda()
		return
	visible = false
	ronda_terminada.emit(ganador)
