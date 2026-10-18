extends Control

const RUTA_DATOS := "res://interfaz/tutorial/datos_tutorial.json"
# Actualizado para que al terminar el tutorial dirija a tu escena de la isla
const RUTA_NIVEL := "res://escenas/mundo.tscn"

# Estilos de textura reutilizando las texturas del menú, para que todos los
# estados del botón "Siguiente" se vean siempre con su textura melocotón.
const TEXTURA_BOTON2_NORMAL := preload("res://recursos/ui/botones/boton2_normal.png")
const TEXTURA_BOTON2_CLIC := preload("res://recursos/ui/botones/boton2_clic.png")
const TEXTURA_JUGAR_NORMAL := preload("res://recursos/ui/botones/boton3_normal.png")
const TEXTURA_JUGAR_CLIC := preload("res://recursos/ui/botones/boton3_clic.png")

@onready var label_titulo: Label = $Layout/Titulo
@onready var label_pagina: Label = $Layout/IndicadorPagina
@onready var caja_1: Label = $Layout/Cajas/CajaIzquierda/Texto
@onready var caja_2: Label = $Layout/Cajas/CajaDerecha/Texto
@onready var caja_3: Label = $Layout/Cajas/CajaCentro/Texto
@onready var boton_atras: Button = $BotonAtras
@onready var boton_siguiente: Button = $BotonSiguiente

var _paginas: Array = []
var _indice: int = 0


func _ready() -> void:
	_cargar_paginas()
	if _paginas.is_empty():
		push_error("Tutorial sin páginas: " + RUTA_DATOS)
		return

	boton_atras.pressed.connect(_pagina_anterior)
	boton_siguiente.pressed.connect(_pagina_siguiente)
	_mostrar_pagina(0)


func _cargar_paginas() -> void:
	var archivo := FileAccess.open(RUTA_DATOS, FileAccess.READ)
	if archivo == null:
		push_error("No se pudo abrir: " + RUTA_DATOS)
		return
	var datos: Dictionary = JSON.parse_string(archivo.get_as_text())
	_paginas = datos.get("paginas", [])


func _mostrar_pagina(indice: int) -> void:
	_indice = clampi(indice, 0, _paginas.size() - 1)
	var pagina: Dictionary = _paginas[_indice]
	var cajas: Array = pagina.get("cajas", [])

	label_titulo.text = str(pagina.get("titulo", ""))
	label_pagina.text = "Página %d / %d" % [_indice + 1, _paginas.size()]

	caja_1.text = str(cajas[0]) if cajas.size() > 0 else ""
	caja_2.text = str(cajas[1]) if cajas.size() > 1 else ""
	caja_3.text = str(cajas[2]) if cajas.size() > 2 else ""

	boton_atras.visible = _indice > 0

	# "Siguiente" con tono cálido (ámbar) para no confundirse con "Atrás".
	boton_siguiente.self_modulate = Color(1.0, 0.86, 0.66)

	var es_ultima: bool = _indice == _paginas.size() - 1
	if es_ultima:
		boton_siguiente.text = "¡Jugar!"
		boton_siguiente.self_modulate = Color(0.85, 0.72, 1.0)
		_estilo_boton(boton_siguiente, TEXTURA_JUGAR_NORMAL, TEXTURA_JUGAR_CLIC)
	else:
		boton_siguiente.text = "Siguiente"
		_estilo_boton(boton_siguiente, TEXTURA_BOTON2_NORMAL, TEXTURA_BOTON2_CLIC)


## Aplica textura melocotón a los cuatro estados visibles del botón, con los
## mismos márgenes (40/30) que los estilos del menú principal.
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


func _pagina_anterior() -> void:
	if _indice > 0:
		_mostrar_pagina(_indice - 1)


func _pagina_siguiente() -> void:
	if _indice < _paginas.size() - 1:
		_mostrar_pagina(_indice + 1)
	else:
		get_tree().change_scene_to_file(RUTA_NIVEL)
