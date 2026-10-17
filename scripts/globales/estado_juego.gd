extends Node

# Datos de la partida actual. Se rellena en la selección de jugador
# y se lee al empezar el nivel. Sobrevive a cambio de escenas (autoload).

signal vidas_cambiadas(jugador: int, vidas: int)

const VIDAS_INICIALES := 3

var personajes: Array = []

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
