class_name Sonidos
extends Node

# Gestor de sonidos del juego (efectos y loops).
# Lo crea el autoload Musica al arrancar, así que se puede usar desde cualquier
# script sin registrar nada más:
#   Sonidos.sfx("correcto")            -> suena una vez
#   Sonidos.iniciar_loop("lanzar_dado") -> suena en bucle hasta detener_loop()

# Dónde está cada sonido. Para cambiar uno, basta con cambiar su ruta aquí.
const RUTAS := {
	"boton": "res://recursos/audio/efectos/boton_seleccion.wav",
	"correcto": "res://recursos/audio/efectos/correcto.wav",
	"incorrecto": "res://recursos/audio/efectos/incorrecto.wav",
	"listo": "res://recursos/audio/efectos/listo.wav",
	"resultado": "res://recursos/audio/efectos/resultado.wav",
	"ganador_ronda": "res://recursos/audio/efectos/ganador_ronda.wav",
	"lanzar_dado": "res://recursos/audio/efectos/lanzar_dado_loop.wav",
	"pregunta": "res://recursos/audio/efectos/pregunta_loop.wav",
	"creditos": "res://recursos/audio/musica/creditos_loop.wav",
}

# Volumen de la música de fondo (en dB): normal, y bajo mientras suena una pregunta.
const VOLUMEN_MUSICA_NORMAL := 0.0
const VOLUMEN_MUSICA_BAJO := -14.0

# La única instancia (la crea Musica). 'static' hace que se pueda llamar
# como Sonidos.sfx(...) sin tener el nodo a mano.
static var instancia: Sonidos

var _cache: Dictionary = {}   # sonidos ya cargados, para no leer el archivo cada vez
var _loops: Dictionary = {}   # loops que están sonando: nombre -> reproductor


# --- Funciones que usa el resto del juego ---------------------------------

static func iniciar(anfitrion: Node) -> void:
	if instancia != null:
		return
	instancia = Sonidos.new()
	instancia.name = "Sonidos"
	anfitrion.add_child(instancia)


# Reproduce un efecto una vez. Puede sonar varias veces a la vez.
static func sfx(nombre: String, volumen_db: float = 0.0) -> void:
	if instancia != null:
		instancia._reproducir_sfx(nombre, volumen_db)


static func iniciar_loop(nombre: String) -> void:
	if instancia != null:
		instancia._iniciar_loop(nombre)


static func detener_loop(nombre: String) -> void:
	if instancia != null:
		instancia._detener_loop(nombre)


# Pregunta en pantalla: suena su loop y baja la música de fondo.
static func pregunta_empezar() -> void:
	if instancia != null:
		instancia._iniciar_loop("pregunta")
		Musica.ajustar_volumen(VOLUMEN_MUSICA_BAJO)


static func pregunta_terminar() -> void:
	if instancia != null:
		instancia._detener_loop("pregunta")
		Musica.ajustar_volumen(VOLUMEN_MUSICA_NORMAL)


# Créditos: el loop reemplaza la música de fondo mientras dura la pantalla.
static func creditos_empezar() -> void:
	if instancia != null:
		Musica.detener()
		instancia._iniciar_loop("creditos")


static func creditos_terminar() -> void:
	if instancia != null:
		instancia._detener_loop("creditos")
		Musica.reanudar()


# --- Por dentro ------------------------------------------------------------

func _ready() -> void:
	# Cada vez que aparece un nodo en el juego, si es un botón le conectamos el clic.
	get_tree().node_added.connect(_al_agregar_nodo)


func _al_agregar_nodo(nodo: Node) -> void:
	# Los botones con su propio sonido (Correcto, Incorrecto, Listo) llevan el
	# metadato "sin_clic" para no sonar doble.
	if nodo is BaseButton and not nodo.has_meta("sin_clic"):
		(nodo as BaseButton).pressed.connect(_reproducir_sfx.bind("boton", 0.0))


func _cargar(nombre: String) -> AudioStream:
	if not RUTAS.has(nombre):
		push_error("Sonidos: no existe el sonido '%s'" % nombre)
		return null
	if not _cache.has(nombre):
		_cache[nombre] = load(RUTAS[nombre])
	return _cache[nombre]


func _reproducir_sfx(nombre: String, volumen_db: float) -> void:
	var flujo: AudioStream = _cargar(nombre)
	if flujo == null:
		return
	# Un reproductor nuevo por sonido: así se pueden solapar y se borran solos.
	var reproductor := AudioStreamPlayer.new()
	reproductor.stream = flujo
	reproductor.volume_db = volumen_db
	add_child(reproductor)
	reproductor.finished.connect(reproductor.queue_free)
	reproductor.play()


func _iniciar_loop(nombre: String) -> void:
	if _loops.has(nombre):
		return
	var flujo: AudioStream = _cargar(nombre)
	if flujo == null:
		return
	_activar_bucle(flujo)
	var reproductor := AudioStreamPlayer.new()
	reproductor.stream = flujo
	add_child(reproductor)
	_loops[nombre] = reproductor
	reproductor.play()


func _detener_loop(nombre: String) -> void:
	if not _loops.has(nombre):
		return
	var reproductor: AudioStreamPlayer = _loops[nombre]
	reproductor.stop()
	reproductor.queue_free()
	_loops.erase(nombre)


# Un WAV no se repite solo: hay que decirle que vuelva al principio al llegar al final.
# El final se calcula con la duración real (Godot importa los WAV comprimidos, así que
# el tamaño en bytes no sirve para contar las muestras).
func _activar_bucle(flujo: AudioStream) -> void:
	if flujo is AudioStreamWAV:
		var wav := flujo as AudioStreamWAV
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
		wav.loop_begin = 0
		wav.loop_end = int(wav.get_length() * wav.mix_rate)
