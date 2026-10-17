extends Node

# Autoload: Godot lo carga al iniciar y es accesible desde cualquier script
# escribiendo EstadoJuego (por ejemplo: EstadoJuego.avanzar(1, 1)).

# Se emite cada vez que un jugador cambia su número de casillas recorridas.
signal casillas_cambiadas(jugador: int, total: int)

# Casillas que lleva recorridas cada jugador. La llave es el número de jugador.
var casillas_recorridas: Dictionary[int, int] = {1: 0, 2: 0}


# Suma 'casillas' al jugador indicado.
func avanzar(jugador: int, casillas: int) -> void:
	casillas_recorridas[jugador] += casillas
	casillas_cambiadas.emit(jugador, casillas_recorridas[jugador])


# Devuelve cuántas casillas lleva recorridas el jugador.
func obtener_casillas(jugador: int) -> int:
	return casillas_recorridas[jugador]


# Deja a todos los jugadores en la casilla de salida.
func reiniciar() -> void:
	for jugador in casillas_recorridas:
		casillas_recorridas[jugador] = 0
		casillas_cambiadas.emit(jugador, 0)
