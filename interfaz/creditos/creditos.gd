extends Control

const RUTA_DATOS := "res://interfaz/creditos/datos_creditos.json"

# Color de los cargos (CREATIVE DIRECTOR, 3D ART...), para distinguirlos de los nombres.
const COLOR_CARGO := Color(0.62, 0.32, 0.16)

@onready var label_titulo: Label = $Centro/Marco/Contenido/Titulo
@onready var columnas: HBoxContainer = $Centro/Marco/Contenido/Columnas
@onready var label_pie: Label = $Centro/Marco/Contenido/Pie
@onready var boton_volver: Button = $Centro/Marco/Contenido/BotonVolver


func _ready() -> void:
	# El loop de créditos reemplaza la música de fondo mientras esta pantalla esté abierta.
	Sonidos.creditos_empezar()
	cargar_creditos()
	boton_volver.pressed.connect(_on_boton_volver_pressed)
	boton_volver.grab_focus()


func cargar_creditos() -> void:
	var archivo := FileAccess.open(RUTA_DATOS, FileAccess.READ)
	if archivo == null:
		push_error("No se pudo abrir: " + RUTA_DATOS)
		return

	var datos: Dictionary = JSON.parse_string(archivo.get_as_text())
	if datos == null:
		push_error("JSON inválido en: " + RUTA_DATOS)
		return

	label_titulo.text = datos.get("titulo", "Créditos")

	# Cada columna del archivo es una lista de secciones (cargo + nombres).
	for datos_columna: Dictionary in datos.get("columnas", []):
		columnas.add_child(_crear_columna(datos_columna))

	# El pie son varias líneas de texto, una debajo de otra.
	label_pie.text = "
".join(PackedStringArray(datos.get("pie", [])))


# Arma una columna: por cada sección, su cargo y debajo los nombres.
func _crear_columna(datos_columna: Dictionary) -> VBoxContainer:
	var columna := VBoxContainer.new()
	columna.add_theme_constant_override("separation", 4)
	columna.custom_minimum_size.x = float(datos_columna.get("ancho", 480))
	var tamano: int = int(datos_columna.get("tamano", 28))
	var alinear: int = HORIZONTAL_ALIGNMENT_LEFT if datos_columna.get("alinear", "centro") == "izquierda" else HORIZONTAL_ALIGNMENT_CENTER

	var es_primera: bool = true
	for seccion: Dictionary in datos_columna.get("secciones", []):
		# Un espacio entre una sección y la siguiente.
		if not es_primera:
			var espacio := Control.new()
			espacio.custom_minimum_size = Vector2(0, 12)
			columna.add_child(espacio)
		es_primera = false

		columna.add_child(_crear_etiqueta(str(seccion.get("rol", "")), mini(tamano, 22), alinear, true))
		for nombre in seccion.get("nombres", []):
			columna.add_child(_crear_etiqueta(str(nombre), tamano, alinear, false))
	return columna


func _crear_etiqueta(texto: String, tamano: int, alinear: int, es_cargo: bool) -> Label:
	var etiqueta := Label.new()
	etiqueta.text = texto
	etiqueta.horizontal_alignment = alinear as HorizontalAlignment
	# Las direcciones web no tienen espacios: se parten donde haga falta para que no se salgan.
	etiqueta.autowrap_mode = TextServer.AUTOWRAP_ARBITRARY
	etiqueta.add_theme_font_size_override("font_size", tamano)
	etiqueta.theme_type_variation = &"TextoOscuro"
	if es_cargo:
		etiqueta.add_theme_color_override("font_color", COLOR_CARGO)
	return etiqueta


func _on_boton_volver_pressed() -> void:
	get_tree().change_scene_to_file("res://interfaz/menu_principal/menu_principal.tscn")


# Al salir de los créditos (por cualquier camino) vuelve la música de fondo.
func _exit_tree() -> void:
	Sonidos.creditos_terminar()
