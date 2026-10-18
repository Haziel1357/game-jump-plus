extends CanvasLayer

# Dos placas, una por jugador (la 1 a la izquierda y la 2 a la derecha). Cada una
# muestra el retrato del personaje elegido, el número de vidas, el nombre y las casillas.
@onready var _paneles: Dictionary = {1: $VidaJugador1, 2: $VidaJugador2}


func _ready() -> void:
	EstadoJuego.vidas_cambiadas.connect(_on_vidas_cambiadas)
	EstadoJuego.casillas_cambiadas.connect(_on_casillas_cambiadas)
	for jugador in _paneles:
		_poner_icono(jugador)
		_refrescar_jugador(jugador)


# Pone en la placa los datos actuales del jugador.
func _refrescar_jugador(jugador: int) -> void:
	_paneles[jugador].get_node("Vidas").text = str(EstadoJuego.vidas_de(jugador))
	_paneles[jugador].get_node("Nombre").text = EstadoJuego.nombre_de(jugador)
	_refrescar_casillas(jugador)


# Ejemplo: "Casillas 3/6"
func _refrescar_casillas(jugador: int) -> void:
	_paneles[jugador].get_node("Casillas").text = "Casillas %d/%d" % [EstadoJuego.obtener_casillas(jugador), EstadoJuego.CASILLAS_PARA_GANAR]


# El retrato es el icono de vidas del personaje que eligió el jugador (personajes.json).
func _poner_icono(jugador: int) -> void:
	var datos: Dictionary = EstadoJuego.jugador_1 if jugador == 1 else EstadoJuego.jugador_2
	var indice: int = int(datos["personaje"])
	if indice < 0 or indice >= EstadoJuego.personajes.size():
		return
	var ruta: String = str(EstadoJuego.personajes[indice].get("icono_vidas", ""))
	if ruta.is_empty():
		return
	_paneles[jugador].get_node("Icono").texture = load(ruta) as Texture2D


func _on_vidas_cambiadas(jugador: int, vidas: int) -> void:
	_paneles[jugador].get_node("Vidas").text = str(vidas)


# Se llama cada vez que un jugador avanza (o se reinician las casillas).
func _on_casillas_cambiadas(jugador: int, _total: int) -> void:
	_refrescar_casillas(jugador)
