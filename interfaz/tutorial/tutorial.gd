extends Control

const RUTA_DATOS := "res://interfaz/tutorial/datos_tutorial.json"
# Actualizado para que al terminar el tutorial dirija a tu escena de la isla
const RUTA_NIVEL := "res://escenas/mundo.tscn"

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

	var es_ultima: bool = _indice == _paginas.size() - 1
	if es_ultima:
		boton_siguiente.text = "¡Jugar!"
		# En la última página, el botón pasa a la versión más adornada.
		boton_siguiente.theme_type_variation = &"Boton3"
	else:
		boton_siguiente.text = "Siguiente"
		boton_siguiente.theme_type_variation = &"Boton2"


func _pagina_anterior() -> void:
	if _indice > 0:
		_mostrar_pagina(_indice - 1)


func _pagina_siguiente() -> void:
	if _indice < _paginas.size() - 1:
		_mostrar_pagina(_indice + 1)
	else:
		get_tree().change_scene_to_file(RUTA_NIVEL)
