extends CanvasLayer

@onready var label_vidas_1: Label = $VidaJugador1/TextoVidas
@onready var label_vidas_2: Label = $VidaJugador2/TextoVidas
@onready var label_casillas_1: Label = $CasillasJugador1
@onready var label_casillas_2: Label = $CasillasJugador2


func _ready() -> void:
	EstadoJuego.vidas_cambiadas.connect(_on_vidas_cambiadas)
	EstadoJuego.casillas_cambiadas.connect(_on_casillas_cambiadas)
	_refrescar_todo()


func _refrescar_todo() -> void:
	label_vidas_1.text = _texto_vidas(1)
	label_vidas_2.text = _texto_vidas(2)
	label_casillas_1.text = _texto_casillas(1)
	label_casillas_2.text = _texto_casillas(2)


# Ejemplo: "Casillas: 3/6"
func _texto_casillas(jugador: int) -> String:
	return "Casillas: %d/%d" % [EstadoJuego.obtener_casillas(jugador), EstadoJuego.CASILLAS_PARA_GANAR]


# Se llama cada vez que un jugador avanza (o se reinician las casillas).
func _on_casillas_cambiadas(jugador: int, _total: int) -> void:
	if jugador == 1:
		label_casillas_1.text = _texto_casillas(1)
	else:
		label_casillas_2.text = _texto_casillas(2)


func _texto_vidas(jugador: int) -> String:
	var nombre: String = EstadoJuego.nombre_de(jugador)
	var vidas: int = EstadoJuego.vidas_de(jugador)
	return "%s  %s (%d)" % [nombre, "♥".repeat(vidas), vidas]


func _on_vidas_cambiadas(jugador: int, _vidas: int) -> void:
	if jugador == 1:
		label_vidas_1.text = _texto_vidas(1)
	else:
		label_vidas_2.text = _texto_vidas(2)
