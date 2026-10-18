extends Node

# Coordina el ciclo del juego:
# dados -> pregunta al ganador -> pregunta al otro jugador -> dados otra vez.
# Gana el primer jugador que llegue a EstadoJuego.CASILLAS_PARA_GANAR casillas.
# También termina la partida si a un jugador se le acaban las vidas.

# Casillas que avanza un jugador cuando su respuesta es correcta.
@export var casillas_por_acierto: int = 1
# Pausa tras marcar la respuesta, para que se vea el banner de "CORRECTO/INCORRECTO".
@export var pausa_tras_respuesta: float = 1.8

# Los personajes se asignan en el Inspector (así sirve en cualquier nivel,
# sin importar cómo se llamen los nodos). Deben tener el script jugador.gd.
@export var jugador_1: Node
@export var jugador_2: Node

# Los nodos hermanos de este nodo dentro de la escena del nivel.
@onready var dado: Dado = $"../Dado"
# Sin tipo a propósito: preguntas.gd no tiene class_name.
@onready var preguntas = $"../Preguntas"
@onready var fin_partida: FinPartida = $"../FinPartida"

var _partida_terminada: bool = false
# Los nodos de los personajes, por número de jugador (se llena en _ready).
var _jugadores: Dictionary = {}


func _ready() -> void:
	if jugador_1 == null or jugador_2 == null:
		push_error("CicloRonda: asigna Jugador 1 y Jugador 2 en el Inspector.")
		return
	_jugadores = {1: jugador_1, 2: jugador_2}
	# Los jugadores ya no se mueven con la tecla de prueba: solo al acertar.
	for jugador in _jugadores:
		_jugadores[jugador].set("habilita_tecla_prueba", false)

	dado.ronda_terminada.connect(_al_terminar_dado)
	# call_deferred espera a que todos los nodos estén listos antes de empezar.
	dado.iniciar_ronda.call_deferred()


# El dado ya decidió quién empieza: preguntamos a ese jugador y luego al otro.
func _al_terminar_dado(ganador: int) -> void:
	var otro: int = 2 if ganador == 1 else 1

	await _preguntar(ganador)
	if _partida_terminada:
		return

	await _preguntar(otro)
	if _partida_terminada:
		return

	# Los dos ya jugaron y nadie ganó: volvemos a tirar el dado.
	dado.iniciar_ronda()


# Pregunta a un jugador y aplica el resultado.
func _preguntar(jugador: int) -> void:
	preguntas.mostrar_pregunta(jugador)
	# Esperamos a que marquen Correcto/Incorrecto; la señal trae la respuesta.
	var es_correcto: bool = await preguntas.resultado_marcado

	# Si fue incorrecto, preguntas.gd ya le restó 1 vida y aquí no se mueve.
	if es_correcto:
		EstadoJuego.avanzar(jugador, casillas_por_acierto)
		# El personaje salta a la siguiente casilla de su camino.
		_jugadores[jugador].call("avanzar_siguiente_punto")

	await get_tree().create_timer(pausa_tras_respuesta).timeout

	# ¿Llegó a la meta? Gana ese jugador, aunque el otro no haya contestado aún.
	if EstadoJuego.obtener_casillas(jugador) >= EstadoJuego.CASILLAS_PARA_GANAR:
		_terminar_partida(jugador)
	# ¿Se quedó sin vidas? Gana el otro.
	elif EstadoJuego.vidas_de(jugador) <= 0:
		_terminar_partida(2 if jugador == 1 else 1)


# Muestra las pantallas finales: "¡Ganaste!" para uno y "Perdiste" para el otro.
func _terminar_partida(ganador: int) -> void:
	_partida_terminada = true
	fin_partida.mostrar(ganador)
