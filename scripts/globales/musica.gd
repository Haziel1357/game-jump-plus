extends Node

const RUTA_MUSICA := "res://recursos/audio/musica/Game Jam - Track 1.wav"

@onready var _reproductor: AudioStreamPlayer = AudioStreamPlayer.new()


func _ready() -> void:
	# Crea el gestor de efectos y loops (scripts/globales/sonidos.gd).
	Sonidos.iniciar(self)
	add_child(_reproductor)
	var stream: AudioStream = load(RUTA_MUSICA)
	if stream == null:
		push_error("No se pudo cargar la música: " + RUTA_MUSICA)
		return

	if stream is AudioStreamWAV:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_begin = 0
		# Duración real en muestras: el tamaño en bytes no sirve porque Godot
		# importa los WAV comprimidos (antes la pista se reiniciaba a los 19 s).
		stream.loop_end = int(stream.get_length() * stream.mix_rate)

	_reproductor.stream = stream
	_reproductor.volume_db = 0.0
	_reproductor.play()


func detener() -> void:
	_reproductor.stop()


func reanudar() -> void:
	if not _reproductor.playing:
		_reproductor.play()


func ajustar_volumen(db: float) -> void:
	_reproductor.volume_db = db
