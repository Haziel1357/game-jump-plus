class_name FinPartida
extends CanvasLayer

# Pantalla final: una ventana para cada jugador ("¡Ganaste!" / "Perdiste")
# con su resumen, y dos botones compartidos: reiniciar y volver al menú.

const RUTA_MENU := "res://interfaz/menu_principal/menu_principal.tscn"

# Tinte de la burbuja de cada ventana: se multiplica con el color de la imagen,
# así que valores claros dejan la burbuja casi crema con un toque verde o rojo.
@export var tinte_gana: Color = Color(0.6, 1.0, 0.65)
@export var tinte_pierde: Color = Color(1.0, 0.6, 0.55)
# Color del título de cada ventana (oscuro, para que se lea sobre la burbuja).
@export var color_titulo_gana: Color = Color(0.05, 0.38, 0.12)
@export var color_titulo_pierde: Color = Color(0.65, 0.08, 0.08)

@onready var panel_1: Panel = $PanelJugador1
@onready var panel_2: Panel = $PanelJugador2
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
	_rellenar(panel_1, titulo_1, resumen_1, 1, ganador == 1)
	_rellenar(panel_2, titulo_2, resumen_2, 2, ganador == 2)
	visible = true
	boton_reiniciar.grab_focus()


# Pinta la burbuja de un jugador (verdosa si ganó, rojiza si perdió) y escribe
# su título y su resumen.
func _rellenar(panel: Panel, titulo: Label, resumen: Label, jugador: int, gano: bool) -> void:
	# Copiamos el estilo del tema para teñir solo esta ventana y no la otra.
	var estilo := panel.get_theme_stylebox("panel").duplicate() as StyleBoxTexture
	estilo.modulate_color = tinte_gana if gano else tinte_pierde
	panel.add_theme_stylebox_override("panel", estilo)

	titulo.text = "¡Ganaste!" if gano else "Perdiste"
	titulo.add_theme_color_override("font_color", color_titulo_gana if gano else color_titulo_pierde)

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
