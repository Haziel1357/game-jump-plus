class_name Dado
extends CanvasLayer

# Se emite al pulsar "Omitir" cuando hay un ganador (1 o 2).
# En caso de empate no se emite: simplemente se repiten los dados.
signal ronda_terminada(ganador: int)

# Duración total de la animación y cada cuánto cambia la cara (en segundos).
@export var duracion_animacion: float = 2.0
@export var intervalo_numeros: float = 0.08

# Las 6 imágenes del dado, EN ORDEN: la posición 0 es la cara del 1,
# la 1 es la cara del 2... y la 5 es la cara del 6. Se asignan en el Inspector.
@export var caras: Array[Texture2D] = []

# Referencias a los nodos hijos ($ significa "busca este hijo por su nombre").
@onready var dado_1: TextureRect = $DadoJugador1
@onready var boton_lanzar_1: Button = $BotonLanzar
@onready var dado_2: TextureRect = $DadoJugador2
@onready var boton_lanzar_2: Button = $BotonLanzar2
@onready var etiqueta_resultado: Label = $EtiquetaResultado
@onready var ventana_resultado: Panel = $VentanaResultado
@onready var boton_omitir: Button = $VentanaResultado/BotonOmitir

# Guardan el número final que sacó cada jugador en la ronda actual.
var resultado_1: int = 0
var resultado_2: int = 0
# Jugador que ganó los dados (0 = empate).
var ganador: int = 0


func _ready() -> void:
	if caras.size() != 6:
		push_error("Dado: asigna las 6 caras del dado en el Inspector (hay %d)." % caras.size())
	boton_lanzar_1.pressed.connect(_lanzar_jugador_1)
	boton_lanzar_2.pressed.connect(_lanzar_jugador_2)
	boton_omitir.pressed.connect(_al_pulsar_omitir)
	iniciar_ronda()


# Muestra el dado y lo deja listo para que el jugador 1 lance.
# Lo llama quien coordina los turnos cuando hay que volver a tirar.
func iniciar_ronda() -> void:
	visible = true
	# Los dados aparecen cuando cada jugador lanza, no antes.
	dado_1.hide()
	dado_2.hide()
	boton_lanzar_2.hide()
	etiqueta_resultado.hide()
	ventana_resultado.hide()
	boton_lanzar_1.show()


func _lanzar_jugador_1() -> void:
	boton_lanzar_1.hide()
	dado_1.show()
	# 'await' espera a que termine la animación antes de seguir con la línea siguiente.
	resultado_1 = await _animar_dado(dado_1)
	# Cuando termina el jugador 1, aparece el botón del jugador 2.
	boton_lanzar_2.show()


func _lanzar_jugador_2() -> void:
	boton_lanzar_2.hide()
	dado_2.show()
	resultado_2 = await _animar_dado(dado_2)
	_mostrar_ganador()


# Muestra caras al azar en el dado durante 'duracion_animacion' segundos
# y devuelve el número final. Usa 'await', así que es una función que "espera".
func _animar_dado(dado: TextureRect) -> int:
	var tiempo: float = 0.0
	Sonidos.iniciar_loop("lanzar_dado")
	while tiempo < duracion_animacion:
		_mostrar_cara(dado, randi_range(1, 6))
		# Esperamos un ratito sin congelar el juego.
		await get_tree().create_timer(intervalo_numeros, false).timeout
		tiempo += intervalo_numeros

	var numero_final: int = randi_range(1, 6)
	_mostrar_cara(dado, numero_final)
	# Termina de rodar: se corta el loop y suena el sonido del número final.
	Sonidos.detener_loop("lanzar_dado")
	Sonidos.sfx("resultado")
	return numero_final


# Pone en el dado la imagen del número indicado (1 a 6).
# Como la lista empieza en 0, la cara del número N está en la posición N - 1.
func _mostrar_cara(dado: TextureRect, numero: int) -> void:
	if caras.size() == 6:
		dado.texture = caras[numero - 1]


# Compara los dos resultados, decide quién empieza y muestra la ventana.
func _mostrar_ganador() -> void:
	if resultado_1 > resultado_2:
		ganador = 1
		etiqueta_resultado.text = "¡Empieza el jugador 1!"
	elif resultado_2 > resultado_1:
		ganador = 2
		etiqueta_resultado.text = "¡Empieza el jugador 2!"
	else:
		ganador = 0
		etiqueta_resultado.text = "¡Empate! Se repite el dado"

	# Si hay ganador suena su sonido (en un empate no suena nada).
	if ganador != 0:
		Sonidos.sfx("ganador_ronda")

	# El botón dice qué pasará al pulsarlo: empezar la ronda o volver a lanzar.
	boton_omitir.text = "Iniciar Ronda" if ganador != 0 else "Vuelvan a Lanzar"
	etiqueta_resultado.show()
	ventana_resultado.show()


# Al pulsar "Omitir": si hubo ganador, se oculta el dado y se avisa a quien
# coordina los turnos; si fue empate, se vuelve a tirar.
func _al_pulsar_omitir() -> void:
	if ganador == 0:
		iniciar_ronda()
		return
	visible = false
	ronda_terminada.emit(ganador)


# Si se sale de la escena a mitad de una tirada (por ejemplo, al reiniciar desde la
# pausa), el loop de los dados no debe quedarse sonando.
func _exit_tree() -> void:
	Sonidos.detener_loop("lanzar_dado")
