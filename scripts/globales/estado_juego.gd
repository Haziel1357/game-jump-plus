extends Node

# Datos de la partida actual. Se rellena en la selección de jugador
# y se lee al empezar el nivel. Sobrevive a cambio de escenas (autoload).

signal vidas_cambiadas(jugador: int, vidas: int)
# Se emite cuando un jugador cambia su número de casillas recorridas.
signal casillas_cambiadas(jugador: int, total: int)

const VIDAS_INICIALES := 3
# Casillas que debe recorrer un jugador para ganar la partida.
const CASILLAS_PARA_GANAR := 6

var personajes: Array = []

# Casillas que lleva recorridas cada jugador. La llave es el número de jugador.
var casillas_recorridas: Dictionary[int, int] = {1: 0, 2: 0}

var jugador_1: Dictionary = {
	"nombre": "Jugador 1",
	"personaje": 0,
	"listo": false,
	"vidas": VIDAS_INICIALES,
}

var jugador_2: Dictionary = {
	"nombre": "Jugador 2",
	"personaje": 1,
	"listo": false,
	"vidas": VIDAS_INICIALES,
}


func _ready() -> void:
	cargar_personajes()


func cargar_personajes() -> void:
	var archivo := FileAccess.open("res://escenas/jugador/personajes.json", FileAccess.READ)
	if archivo == null:
		push_error("No se pudo abrir res://escenas/jugador/personajes.json")
		return
	var datos: Dictionary = JSON.parse_string(archivo.get_as_text())
	personajes = datos.get("personajes", [])


func reiniciar_seleccion() -> void:
	jugador_1 = {"nombre": "Jugador 1", "personaje": 0, "listo": false, "vidas": VIDAS_INICIALES}
	jugador_2 = {"nombre": "Jugador 2", "personaje": 1, "listo": false, "vidas": VIDAS_INICIALES}
	reiniciar_casillas()


# Vuelve a empezar la partida conservando nombres y personajes elegidos.
func reiniciar_partida() -> void:
	jugador_1["vidas"] = VIDAS_INICIALES
	jugador_2["vidas"] = VIDAS_INICIALES
	reiniciar_casillas()


func ambos_listos() -> bool:
	return jugador_1["listo"] and jugador_2["listo"]


func restar_vida(jugador: int) -> void:
	var datos: Dictionary = _datos_jugador(jugador)
	if datos.is_empty():
		return
	datos["vidas"] = maxi(0, int(datos["vidas"]) - 1)
	vidas_cambiadas.emit(jugador, datos["vidas"])


func vidas_de(jugador: int) -> int:
	return int(_datos_jugador(jugador).get("vidas", 0))


func nombre_de(jugador: int) -> String:
	return str(_datos_jugador(jugador).get("nombre", ""))


func _datos_jugador(jugador: int) -> Dictionary:
	if jugador == 1:
		return jugador_1
	if jugador == 2:
		return jugador_2
	return {}


# Suma 'casillas' al jugador indicado (por ejemplo: EstadoJuego.avanzar(1, 1)).
func avanzar(jugador: int, casillas: int) -> void:
	casillas_recorridas[jugador] += casillas
	casillas_cambiadas.emit(jugador, casillas_recorridas[jugador])


# Devuelve cuántas casillas lleva recorridas el jugador.
func obtener_casillas(jugador: int) -> int:
	return casillas_recorridas[jugador]


# Deja a todos los jugadores en la casilla de salida.
func reiniciar_casillas() -> void:
	for jugador in casillas_recorridas:
		casillas_recorridas[jugador] = 0
		casillas_cambiadas.emit(jugador, 0)
