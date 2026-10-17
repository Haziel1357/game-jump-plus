extends Area3D

# Se ejecuta una vez, cuando el nodo entra a la escena.
func _ready() -> void:
	# Conectamos la señal "body_entered" (alguien entró a la zona)
	# con nuestra función. Es como decir: "avísame cuando pisen el botón".
	body_entered.connect(_al_entrar_cuerpo)


# Godot llama a esta función cada vez que un cuerpo físico entra al área.
# 'cuerpo' es el nodo que entró (en nuestro caso, el Jugador).
func _al_entrar_cuerpo(cuerpo: Node3D) -> void:
	print("¡Botón pisado por: ", cuerpo.name, "!")
