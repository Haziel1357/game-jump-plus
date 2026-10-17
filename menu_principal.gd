extends Control

# Referencias a los botones del menú (asignados por nombre en la escena).
@onready var boton_nuevo_juego: Button = $Centro/Botones/BotonNuevoJuego
@onready var boton_creditos: Button = $Centro/Botones/BotonCreditos
@onready var boton_salir: Button = $Centro/Botones/BotonSalir


func _ready() -> void:
	boton_nuevo_juego.pressed.connect(_on_boton_nuevo_juego_pressed)
	boton_creditos.pressed.connect(_on_boton_creditos_pressed)
	boton_salir.pressed.connect(_on_boton_salir_pressed)

	# El foco inicial va a "Salir" para poder navegar con teclado desde ahí.
	boton_salir.grab_focus()


func _on_boton_nuevo_juego_pressed() -> void:
	# TODO: cargar la escena del juego (mundo.tscn).
	print("TODO: Nuevo Juego")


func _on_boton_creditos_pressed() -> void:
	# TODO: mostrar pantalla de créditos.
	print("TODO: Créditos")


func _on_boton_salir_pressed() -> void:
	# Cierra la aplicación de forma limpia.
	get_tree().quit()
