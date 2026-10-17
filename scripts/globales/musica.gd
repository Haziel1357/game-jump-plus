extends Node

const RUTA_MUSICA := "res://recursos/audio/musica/Game Jam - Track 1.wav"

@onready var _reproductor: AudioStreamPlayer = AudioStreamPlayer.new()


func _ready() -> void:
	add_child(_reproductor)
	var stream: AudioStream = load(RUTA_MUSICA)
	if stream == null:
		push_error("No se pudo cargar la música: " + RUTA_MUSICA)
		return

	if stream is AudioStreamWAV:
		var bytes_por_muestra: int = 1 if stream.format == AudioStreamWAV.FORMAT_8_BITS else 2
		var canales: int = 2 if stream.stereo else 1
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_begin = 0
		stream.loop_end = stream.data.size() / (bytes_por_muestra * canales)

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
