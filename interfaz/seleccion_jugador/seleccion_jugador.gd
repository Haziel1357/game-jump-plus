extends Control

const RUTA_TUTORIAL := "res://interfaz/tutorial/tutorial.tscn"

@onready var preview_1: ColorRect = $Layout/Paneles/PanelJugador1/Contenido/Preview/ColorPersonaje
@onready var nombre_personaje_1: Label = $Layout/Paneles/PanelJugador1/Contenido/Preview/NombrePersonaje
@onready var nick_1: LineEdit = $Layout/Paneles/PanelJugador1/Contenido/CampoNick
@onready var boton_listo_1: Button = $Layout/Paneles/PanelJugador1/Contenido/BotonListo

@onready var preview_2: ColorRect = $Layout/Paneles/PanelJugador2/Contenido/Preview/ColorPersonaje
@onready var nombre_personaje_2: Label = $Layout/Paneles/PanelJugador2/Contenido/Preview/NombrePersonaje
@onready var nick_2: LineEdit = $Layout/Paneles/PanelJugador2/Contenido/CampoNick
@onready var boton_listo_2: Button = $Layout/Paneles/PanelJugador2/Contenido/BotonListo

@onready var boton_volver: Button = $BotonVolver

var _partida_iniciada: bool = false


func _ready() -> void:
	EstadoJuego.reiniciar_seleccion()

	nick_1.text = EstadoJuego.jugador_1["nombre"]
	nick_2.text = EstadoJuego.jugador_2["nombre"]

	$Layout/Paneles/PanelJugador1/Contenido/Flechas/BotonAnterior.pressed.connect(_cambiar_personaje.bind(-1, 1))
	$Layout/Paneles/PanelJugador1/Contenido/Flechas/BotonSiguiente.pressed.connect(_cambiar_personaje.bind(1, 1))
	$Layout/Paneles/PanelJugador2/Contenido/Flechas/BotonAnterior.pressed.connect(_cambiar_personaje.bind(-1, 2))
	$Layout/Paneles/PanelJugador2/Contenido/Flechas/BotonSiguiente.pressed.connect(_cambiar_personaje.bind(1, 2))

	boton_listo_1.pressed.connect(_alternar_listo.bind(1))
	boton_listo_2.pressed.connect(_alternar_listo.bind(2))
	boton_volver.pressed.connect(_volver_al_menu)

	nick_1.text_changed.connect(_actualizar_nick.bind(1))
	nick_2.text_changed.connect(_actualizar_nick.bind(2))

	_refrescar_vista(1)
	_refrescar_vista(2)


func _cambiar_personaje(paso: int, jugador: int) -> void:
	var total: int = EstadoJuego.personajes.size()
	if total == 0:
		return

	var datos: Dictionary = EstadoJuego.jugador_1 if jugador == 1 else EstadoJuego.jugador_2
	# Un jugador no puede tomar el personaje del otro si el otro ya está listo.
	var otro: Dictionary = EstadoJuego.jugador_2 if jugador == 1 else EstadoJuego.jugador_1
	var indice: int = int(datos["personaje"]) + paso

	for _intento in range(total):
		indice = wrapi(indice, 0, total)
		if not (bool(otro["listo"]) and int(otro["personaje"]) == indice):
			break
		indice += paso

	datos["personaje"] = indice
	_refrescar_vista(jugador)


func _refrescar_vista(jugador: int) -> void:
	var datos: Dictionary = EstadoJuego.jugador_1 if jugador == 1 else EstadoJuego.jugador_2
	var personaje: Dictionary = EstadoJuego.personajes[int(datos["personaje"])]
	var color: Color = Color(personaje.get("color", "#ffffff"))
	var texto: String = str(personaje.get("nombre", "?"))

	if jugador == 1:
		preview_1.color = color
		nombre_personaje_1.text = texto
	else:
		preview_2.color = color
		nombre_personaje_2.text = texto


func _actualizar_nick(texto: String, jugador: int) -> void:
	var nick: String = texto.strip_edges()
	if nick.is_empty():
		nick = "Jugador %d" % jugador
	if jugador == 1:
		EstadoJuego.jugador_1["nombre"] = nick
	else:
		EstadoJuego.jugador_2["nombre"] = nick


func _alternar_listo(jugador: int) -> void:
	var datos: Dictionary = EstadoJuego.jugador_1 if jugador == 1 else EstadoJuego.jugador_2
	datos["listo"] = not bool(datos["listo"])

	var boton: Button = boton_listo_1 if jugador == 1 else boton_listo_2
	if bool(datos["listo"]):
		boton.text = "¡Listo!"
		boton.add_theme_stylebox_override("normal", _estilo_listo_activo())
	else:
		boton.text = "Listo"
		boton.remove_theme_stylebox_override("normal")

	_comprobar_inicio()


func _estilo_listo_activo() -> StyleBoxFlat:
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color(0.95, 0.75, 0.15)
	estilo.border_color = Color(0.45, 0.35, 0.05)
	estilo.set_border_width_all(3)
	estilo.set_corner_radius_all(12)
	estilo.set_content_margin_all(20)
	return estilo


func _comprobar_inicio() -> void:
	if _partida_iniciada or not EstadoJuego.ambos_listos():
		return
	_partida_iniciada = true
	# Pequeña espera para que se vea el estado "¡Listo!" de ambos.
	await get_tree().create_timer(0.8).timeout
	get_tree().change_scene_to_file(RUTA_TUTORIAL)


func _volver_al_menu() -> void:
	get_tree().change_scene_to_file("res://interfaz/menu_principal/menu_principal.tscn")
