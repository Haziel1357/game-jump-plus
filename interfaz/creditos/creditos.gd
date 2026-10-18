extends Control

const RUTA_DATOS := "res://interfaz/creditos/datos_creditos.json"

@onready var label_titulo: Label = $Centro/Contenido/Titulo
@onready var lista_equipo: VBoxContainer = $Centro/Contenido/Equipo
@onready var boton_volver: Button = $MargenVolver/BotonVolver


func _ready() -> void:
	cargar_creditos()
	boton_volver.pressed.connect(_on_boton_volver_pressed)

	# Sin foco inicial: así el botón no arranca resaltado.


func _unhandled_input(event: InputEvent) -> void:
	# La navegación con teclado empieza al primer intento, pero sin marcar
	# foco mientras el usuario no lo pida (ni al cargar la escena).
	if get_viewport().gui_get_focus_owner() != null:
		return

	if (
		event.is_action_pressed("ui_up")
		or event.is_action_pressed("ui_down")
		or event.is_action_pressed("ui_left")
		or event.is_action_pressed("ui_right")
		or event.is_action_pressed("ui_accept")
	):
		boton_volver.grab_focus()
		get_viewport().set_input_as_handled()


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

	for nombre: String in datos.get("equipo", []):
		var label := Label.new()
		label.text = nombre
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 32)
		lista_equipo.add_child(label)


func _on_boton_volver_pressed() -> void:
	get_tree().change_scene_to_file("res://interfaz/menu_principal/menu_principal.tscn")
