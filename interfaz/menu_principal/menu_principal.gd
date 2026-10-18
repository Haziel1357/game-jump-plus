extends Control

# Referencias a los botones del menú (asignados por nombre en la escena).
@onready var boton_nuevo_juego: Button = $Centro/Botones/BotonNuevoJuego
@onready var boton_creditos: Button = $Centro/Botones/BotonCreditos
@onready var boton_salir: Button = $Centro/Botones/BotonSalir


func _ready() -> void:
	boton_nuevo_juego.pressed.connect(_on_boton_nuevo_juego_pressed)
	boton_creditos.pressed.connect(_on_boton_creditos_pressed)
	boton_salir.pressed.connect(_on_boton_salir_pressed)

	# Sin foco inicial: así ningún botón arranca resaltado.


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
		boton_nuevo_juego.grab_focus()
		get_viewport().set_input_as_handled()


func _on_boton_nuevo_juego_pressed() -> void:
	get_tree().change_scene_to_file("res://interfaz/seleccion_jugador/seleccion_jugador.tscn")


func _on_boton_creditos_pressed() -> void:
	get_tree().change_scene_to_file("res://interfaz/creditos/creditos.tscn")


func _on_boton_salir_pressed() -> void:
	# Cierra la aplicación de forma limpia.
	get_tree().quit()
