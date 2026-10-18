class_name Agua
extends MeshInstance3D

# Capa de agua decorativa que sube cada vez que un jugador pierde una vida.
# Va en un MeshInstance3D con una malla plana (PlaneMesh) grande.

# Altura (eje Y) del agua al empezar la partida.
@export var altura_inicial: float = 0.5
# Cuánto sube el agua por cada vida perdida.
@export var altura_por_nivel: float = 0.8
# Segundos que tarda en subir un nivel.
@export var duracion_subida: float = 1.2
# Segundos que tarda la inundación final (cuando un jugador pierde todas sus vidas).
@export var duracion_inundacion: float = 2.5
# Cuánto por encima de la casilla del jugador debe llegar el agua al inundar.
@export var margen_inundacion: float = 0.4
# Color temporal del agua (celeste/mar). Si el nodo ya tiene un material, se usa ese.
@export var color_agua: Color = Color(0.1, 0.5, 0.75, 0.65)

var _tween: Tween


func _ready() -> void:
	_crear_material_si_falta()

	# Si ya se perdieron vidas (por ejemplo al recargar), arrancamos en ese nivel.
	global_position.y = _altura_del_nivel(_nivel_actual())
	EstadoJuego.vidas_cambiadas.connect(_al_cambiar_vidas)


# Si no le pusiste material en el editor, creamos uno azul transparente.
func _crear_material_si_falta() -> void:
	if material_override != null:
		return
	var material := StandardMaterial3D.new()
	material.albedo_color = color_agua
	# TRANSPARENCY_ALPHA deja ver a través del agua.
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.roughness = 0.1
	material_override = material


# Nivel de agua = total de vidas perdidas entre los dos jugadores.
func _nivel_actual() -> int:
	var vidas_totales: int = EstadoJuego.VIDAS_INICIALES * 2
	return vidas_totales - EstadoJuego.vidas_de(1) - EstadoJuego.vidas_de(2)


func _altura_del_nivel(nivel: int) -> float:
	return altura_inicial + nivel * altura_por_nivel


# Se llama cada vez que un jugador pierde una vida: el agua sube un nivel.
func _al_cambiar_vidas(_jugador: int, _vidas: int) -> void:
	_mover_a(_altura_del_nivel(_nivel_actual()), duracion_subida)


# Inundación final: sube hasta la altura de la casilla de un jugador.
# Usa 'await' para que quien la llame pueda esperar a que termine.
func inundar_hasta(altura_casilla: float) -> void:
	await _mover_a(altura_casilla + margen_inundacion, duracion_inundacion)


# Sube (o baja) suavemente hasta 'altura' en 'segundos'.
func _mover_a(altura: float, segundos: float) -> void:
	# Si ya había una subida en curso, la cancelamos para no pelear con ella.
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_SINE)
	_tween.set_ease(Tween.EASE_IN_OUT)
	_tween.tween_property(self, "global_position:y", altura, segundos)
	await _tween.finished
