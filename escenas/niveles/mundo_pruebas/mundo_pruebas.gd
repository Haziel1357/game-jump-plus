extends Node3D

# Atajos de prueba mientras no hay pausa ni HUD:
# ESC → volver al menú principal.


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://interfaz/menu_principal/menu_principal.tscn")
