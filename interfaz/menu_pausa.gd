extends CanvasLayer

@export var boton_reanudar: Button
@export var boton_reiniciar: Button
@export var boton_menu: Button


func _ready() -> void:
	hide()
	process_mode = PROCESS_MODE_ALWAYS

	# Asegurar que los botones procesen eventos durante la pausa
	if boton_reanudar:
		boton_reanudar.process_mode = PROCESS_MODE_ALWAYS
		boton_reanudar.pressed.connect(_on_reanudar_pressed)
		
	if boton_reiniciar:
		boton_reiniciar.process_mode = PROCESS_MODE_ALWAYS
		boton_reiniciar.pressed.connect(_on_reiniciar_pressed)
		
	if boton_menu:
		boton_menu.process_mode = PROCESS_MODE_ALWAYS
		boton_menu.pressed.connect(_on_menu_pressed)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if get_tree().paused:
			_reanudar()
		else:
			_pausar()


func _pausar() -> void:
	get_tree().paused = true
	show()


func _reanudar() -> void:
	get_tree().paused = false
	hide()


func _on_reanudar_pressed() -> void:
	_reanudar()


func _on_reiniciar_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://interfaz/menu_principal/menu_principal.tscn")
