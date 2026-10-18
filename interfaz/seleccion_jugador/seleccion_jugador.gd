extends Control

# Apuntamos a la pantalla del tutorial de tu compañero
const RUTA_TUTORIAL := "res://interfaz/tutorial/tutorial.tscn"

@onready var nombre_personaje_1: Label = $Layout/Paneles/PanelJugador1/Contenido/Preview/NombrePersonaje
@onready var nick_1: LineEdit = $Layout/Paneles/PanelJugador1/Contenido/CampoNick
@onready var boton_listo_1: Button = $Layout/Paneles/PanelJugador1/Contenido/BotonListo
@onready var contenedor_modelo_1: Node3D = $Layout/Paneles/PanelJugador1/Contenido/Preview/ViewportPersonaje/SubViewport/ContenedorModelo

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
	var texto: String = str(personaje.get("nombre", "?"))
	# La ruta del modelo viene de personajes.json (la misma que usa el nivel).
	var ruta: String = str(personaje.get("modelo", ""))
	var anim_idle: String = str(personaje.get("anim_idle", ""))

	if jugador == 1:
		nombre_personaje_1.text = texto
		_cargar_modelo(contenedor_modelo_1, ruta, anim_idle)
	else:
		nombre_personaje_2.text = texto
		_cargar_modelo(contenedor_modelo_2, ruta, anim_idle)


## Instancia el modelo 3D del personaje y reproduce su animación de reposo.
func _cargar_modelo(contenedor: Node3D, ruta: String, anim_idle: String) -> void:
	# free() en vez de queue_free() para que no se acumulen modelos entre frames.
	for hijo in contenedor.get_children():
		hijo.free()

	if ruta.is_empty():
		push_warning("Este personaje no tiene 'modelo' en personajes.json")
		return

	var modelo: PackedScene
	if _modelos_cargados.has(ruta):
		modelo = _modelos_cargados[ruta]
	else:
		modelo = load(ruta)
		if modelo == null:
			push_error("No se pudo cargar: " + ruta)
			return
		_modelos_cargados[ruta] = modelo

	var instancia: Node3D = modelo.instantiate()
	instancia.position = Vector3.ZERO
	_desactivar_nodos_incasados(instancia)
	contenedor.add_child(instancia)

	# Animación de reposo en bucle, como se ve en el juego.
	for nodo in instancia.find_children("*", "AnimationPlayer", true, false):
		var reproductor := nodo as AnimationPlayer
		if reproductor.has_animation(anim_idle):
			reproductor.get_animation(anim_idle).loop_mode = Animation.LOOP_LINEAR
			reproductor.play(anim_idle)


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
		Sonidos.sfx("listo")
		# La versión más adornada del botón marca que este jugador ya está listo.
		boton.theme_type_variation = &"Boton3"
	else:
		boton.text = "Listo"
		boton.theme_type_variation = &"Boton2"

	_comprobar_inicio()


func _comprobar_inicio() -> void:
	if _partida_iniciada or not EstadoJuego.ambos_listos():
		return
	_partida_iniciada = true
	await get_tree().create_timer(0.8).timeout
	# Redirige a la pantalla del tutorial de tu compañero
	get_tree().change_scene_to_file(RUTA_TUTORIAL)


func _volver_al_menu() -> void:
	get_tree().change_scene_to_file("res://interfaz/menu_principal/menu_principal.tscn")
