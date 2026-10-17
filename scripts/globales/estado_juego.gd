extends Node

# Datos de la partida actual. Se rellena en la selección de jugador
# y se lee al empezar el nivel. Sobrevive a cambio de escenas (autoload).

var personajes: Array = []

var jugador_1: Dictionary = {
	"nombre": "Jugador 1",
	"personaje": 0,
	"listo": false,
}

var jugador_2: Dictionary = {
	"nombre": "Jugador 2",
	"personaje": 1,
	"listo": false,
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
	jugador_1 = {"nombre": "Jugador 1", "personaje": 0, "listo": false}
	jugador_2 = {"nombre": "Jugador 2", "personaje": 1, "listo": false}


func ambos_listos() -> bool:
	return jugador_1["listo"] and jugador_2["listo"]
