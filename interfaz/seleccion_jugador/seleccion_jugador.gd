extends Control

# Apuntamos a la pantalla del tutorial de tu compañero
const RUTA_TUTORIAL := "res://interfaz/tutorial/tutorial.tscn"

const MODELOS := [
	"res://jugadores/jugador_1/robot!_3.tscn",
	"res://jugadores/jugador_2/robot.tscn",
]

# Compartido con el nivel (isla) para que el coloreado sea idéntico.
const TintePersonaje := preload("res://scripts/globales/tinte_personaje.gd")

# Texturas de botones del menú para estilo consistente
const TEXTURA_BOTON1_NORMAL := preload("res://recursos/ui/botones/boton1_normal.png")
const TEXTURA_BOTON1_CLIC := preload("res://recursos/ui/botones/boton1_clic.png")
const TEXTURA_BOTON2_NORMAL := preload("res://recursos/ui/botones/boton2_normal.png")
const TEXTURA_BOTON2_CLIC := preload("res://recursos/ui/botones/boton2_clic.png")
const TEXTURA_BOTON3_NORMAL := preload("res://recursos/ui/botones/boton3_normal.png")
const TEXTURA_BOTON3_CLIC := preload("res://recursos/ui/botones/boton3_clic.png")

@onready var preview_1: ColorRect = $Layout/Paneles/PanelJugador1/Contenido/Preview/ColorPersonaje
@onready var nombre_personaje_1: Label = $Layout/Paneles/PanelJugador1/Contenido/Preview/NombrePersonaje
@onready var nick_1: LineEdit = $Layout/Paneles/PanelJugador1/Contenido/CampoNick
@onready var boton_listo_1: Button = $Layout/Paneles/PanelJugador1/Contenido/BotonListo
@onready var contenedor_modelo_1: Node3D = $Layout/Paneles/PanelJugador1/Contenido/Preview/ViewportPersonaje/SubViewport/ContenedorModelo

@onready var preview_2: ColorRect = $Layout/Paneles/PanelJugador2/Contenido/Preview/ColorPersonaje
@onready var nombre_personaje_2: Label = $Layout/Paneles/PanelJugador2/Contenido/Preview/NombrePersonaje
@onready var nick_2: LineEdit = $Layout/Paneles/PanelJugador2/Contenido/CampoNick
@onready var boton_listo_2: Button = $Layout/Paneles/PanelJugador2/Contenido/BotonListo
@onready var contenedor_modelo_2: Node3D = $Layout/Paneles/PanelJugador2/Contenido/Preview/ViewportPersonaje/SubViewport/ContenedorModelo

@onready var boton_volver: Button = $BotonVolver

var _partida_iniciada: bool = false
var _modelos_cargados: Dictionary = {}


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

	# Estilos de botones con texturas del menú
	_estilo_boton(boton_listo_1, TEXTURA_BOTON2_NORMAL, TEXTURA_BOTON2_CLIC)
	_estilo_boton(boton_listo_2, TEXTURA_BOTON2_NORMAL, TEXTURA_BOTON2_CLIC)
	_estilo_boton(boton_volver, TEXTURA_BOTON1_NORMAL, TEXTURA_BOTON1_CLIC)

	_refrescar_vista(1)
	_refrescar_vista(2)

	# Con solo 2 personajes las flechas no sirven (cada uno tiene el suyo).
	if EstadoJuego.personajes.size() <= 2:
		$Layout/Paneles/PanelJugador1/Contenido/Flechas.visible = false
		$Layout/Paneles/PanelJugador2/Contenido/Flechas.visible = false


func _cambiar_personaje(paso: int, jugador: int) -> void:
	var total: int = EstadoJuego.personajes.size()
	if total == 0:
		return

	var datos: Dictionary = EstadoJuego.jugador_1 if jugador == 1 else EstadoJuego.jugador_2
	var otro: Dictionary = EstadoJuego.jugador_2 if jugador == 1 else EstadoJuego.jugador_1
	var indice: int = int(datos["personaje"]) + paso

	for _intento in range(total):
		indice = wrapi(indice, 0, total)
		if int(otro["personaje"]) != indice:
			break
		indice += paso

	datos["personaje"] = indice
	_refrescar_vista(jugador)


func _refrescar_vista(jugador: int) -> void:
	var datos: Dictionary = EstadoJuego.jugador_1 if jugador == 1 else EstadoJuego.jugador_2
	var indice: int = int(datos["personaje"])
	var personaje: Dictionary = EstadoJuego.personajes[indice]
	var color: Color = Color(personaje.get("color", "#ffffff"))
	var texto: String = str(personaje.get("nombre", "?"))

	if jugador == 1:
		preview_1.color = color
		nombre_personaje_1.text = texto
		_cargar_modelo(contenedor_modelo_1, indice, color)
	else:
		preview_2.color = color
		nombre_personaje_2.text = texto
		_cargar_modelo(contenedor_modelo_2, indice, color)


## Instancia el modelo 3D del personaje y le aplica el color como tinte.
func _cargar_modelo(contenedor: Node3D, indice: int, color: Color) -> void:
	# free() en vez de queue_free() para que no se acumulen modelos entre frames.
	for hijo in contenedor.get_children():
		hijo.free()

	if MODELOS.is_empty():
		push_warning("No hay modelos de personaje definidos en MODELOS.")
		return
	if indice < 0 or indice >= EstadoJuego.personajes.size():
		push_warning("Índice de personaje fuera de rango: %d" % indice)
		return

	# Hay más personajes (colores) que modelos: se reciclan con el resto
	# para que Verde vuelva a usar el modelo 0 y Amarillo el modelo 1.
	var indice_modelo: int = indice % MODELOS.size()

	var modelo: PackedScene
	if _modelos_cargados.has(indice_modelo):
		modelo = _modelos_cargados[indice_modelo]
	else:
		modelo = load(MODELOS[indice_modelo])
		if modelo == null:
			push_error("No se pudo cargar: " + MODELOS[indice_modelo])
			return
		_modelos_cargados[indice_modelo] = modelo

	var instancia: Node3D = modelo.instantiate()
	instancia.position = Vector3.ZERO
	_desactivar_nodos_incasados(instancia)
	contenedor.add_child(instancia)
	TintePersonaje.aplicar(instancia, color)


## Algunos .blend traen su propia cámara y luces; en el preview usamos las nuestras.
func _desactivar_nodos_incasados(nodo: Node) -> void:
	# free() porque esto se ejecuta antes de add_child (nodo aún fuera del árbol).
	for hijo in nodo.get_children().duplicate():
		if hijo is Camera3D or hijo is Light3D:
			hijo.free()
		else:
			_desactivar_nodos_incasados(hijo)


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
		# Usa botón 3 (más destacado) para estado "listo"
		boton.self_modulate = Color(0.85, 0.72, 1.0)
		_estilo_boton(boton, TEXTURA_BOTON3_NORMAL, TEXTURA_BOTON3_CLIC)
	else:
		boton.text = "Listo"
		# Vuelve a botón 2 (melocotón)
		boton.self_modulate = Color(1.0, 0.86, 0.66)
		_estilo_boton(boton, TEXTURA_BOTON2_NORMAL, TEXTURA_BOTON2_CLIC)

	_comprobar_inicio()


## Aplica textura a los cuatro estados visibles del botón con márgenes 40/30
func _estilo_boton(boton: Button, textura_normal: Texture2D, textura_clic: Texture2D) -> void:
	for estado in ["normal", "hover", "pressed", "focus"]:
		var textura := textura_normal if estado == "normal" else textura_clic
		var estilo := StyleBoxTexture.new()
		estilo.texture = textura
		estilo.content_margin_left = 40.0
		estilo.content_margin_top = 30.0
		estilo.content_margin_right = 40.0
		estilo.content_margin_bottom = 30.0
		boton.add_theme_stylebox_override(estado, estilo)


func _comprobar_inicio() -> void:
	if _partida_iniciada or not EstadoJuego.ambos_listos():
		return
	_partida_iniciada = true
	await get_tree().create_timer(0.8).timeout
	# Redirige a la pantalla del tutorial de tu compañero
	get_tree().change_scene_to_file(RUTA_TUTORIAL)


func _volver_al_menu() -> void:
	get_tree().change_scene_to_file("res://interfaz/menu_principal/menu_principal.tscn")