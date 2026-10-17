extends CanvasLayer

# @onready espera a que la escena esté lista y entonces guarda
# una referencia a cada nodo hijo (el $ significa "busca este hijo").
@onready var etiqueta_numero: Label = $EtiquetaNumero
@onready var boton_lanzar: Button = $BotonLanzar


func _ready() -> void:
	# Cuando se haga clic en el botón, se llama a lanzar_dado().
	boton_lanzar.pressed.connect(lanzar_dado)


func lanzar_dado() -> void:
	# randi_range(1, 6) devuelve un entero al azar entre 1 y 6, ambos incluidos.
	var resultado: int = randi_range(1, 6)
	# str() convierte el número en texto para poder mostrarlo en el Label.
	etiqueta_numero.text = str(resultado)
	print("Dado: ", resultado)
