class_name FinPartida
extends CanvasLayer

# Pantalla final: una ventana para cada jugador ("¡Ganaste!" / "Perdiste")
# con su resumen, y dos botones compartidos: reiniciar y volver al menú.

const RUTA_MENU := "res://interfaz/menu_principal/menu_principal.tscn"

const COLOR_GANA := Color(0.25, 0.85, 0.35)
const COLOR_PIERDE := Color(0.95, 0.3, 0.3)

@onready var titulo_1: Label = $PanelJugador1/Titulo
@onready var resumen_1: Label = $PanelJugador1/Resumen
@onready var titulo_2: Label = $PanelJugador2/Titulo
@onready var resumen_2: Label = $PanelJugador2/Resumen
@onready var boton_reiniciar: Button = $Botones/BotonReiniciar
@onready var boton_menu: Button = $Botones/BotonMenu


func _ready() -> void:
	# En el editor se deja visible para poder acomodarla; al jugar empieza oculta.
	visible = false
	boton_reiniciar.pressed.connect(_reiniciar)
	boton_menu.pressed.connect(_ir_al_menu)


# Muestra las dos ventanas: la del 'ganador' dice "¡Ganaste!" y la otra "Perdiste".
func mostrar(ganador: int) -> void:
	_rellenar(titulo_1, resumen_1, 1, ganador == 1)
	_rellenar(titulo_2, resumen_2, 2, ganador == 2)
	visible = true
	boton_reiniciar.grab_focus()


# Escribe el título y el resumen de un jugador.
func _rellenar(titulo: Label, resumen: Label, jugador: int, gano: bool) -> void:
	titulo.text = "¡Ganaste!" if gano else "Perdiste"
	titulo.add_theme_color_override("font_color", COLOR_GANA if gano else COLOR_PIERDE)

	var vidas: int = EstadoJuego.vidas_de(jugador)
	var vidas_perdidas: int = EstadoJuego.VIDAS_INICIALES - vidas
	# Cada acierto suma una casilla, así que las casillas son los aciertos.
	resumen.text = "%s\nAciertos: %d de %d\nVidas: %s%s (%d de %d)" % [
		EstadoJuego.nombre_de(jugador),
		EstadoJuego.obtener_casillas(jugador),
		EstadoJuego.CASILLAS_PARA_GANAR,
		"♥".repeat(vidas),
		"♡".repeat(vidas_perdidas),
		vidas,
		EstadoJuego.VIDAS_INICIALES,
	]


# Empieza otra partida con los mismos jugadores y personajes.
func _reiniciar() -> void:
	EstadoJuego.reiniciar_partida()
	get_tree().reload_current_scene()


func _ir_al_menu() -> void:
	get_tree().change_scene_to_file(RUTA_MENU)
