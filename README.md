# GameJamPlus

Juego de fiesta estilo Mario Party para 2 jugadores en local.

## Convenciones de nombres

| Qué | Formato | Ejemplo |
|---|---|---|
| Carpetas | snake_case | `menu_principal/` |
| Archivos (`.tscn`, `.gd`, `.png` ...) | snake_case | `jugador.gd`, `nivel_01.tscn` |
| Nodos en el árbol de escena | PascalCase | `Jugador`, `CamaraSeguimiento` |
| Variables y funciones | snake_case | `velocidad`, `recibir_dano()` |
| Constantes | MAYUSCULAS | `VELOCIDAD_MAXIMA` |
| Señales | snake_case en pasado | `vida_cambiada`, `jugador_murio` |
| Nombres de clase (`class_name`) | PascalCase | `class_name Jugador` |

## Estructura del proyecto

```
escenas/                  # Todo lo que es "una cosa" del juego
├── jugador/
│   ├── jugador.gd
│   └── modelo/
├── enemigos/
│   └── slime/
├── objetos/
│   └── moneda/
└── niveles/
    ├── nivel_01/
    └── mundo_pruebas/

interfaz/                 # Menús y HUD
├── menu_principal/
├── seleccion_jugador/
├── creditos/
└── hud/

recursos/                 # Assets compartidos
├── materiales/
├── texturas/
├── modelos/
├── audio/
│   ├── musica/
│   └── efectos/
└── fuentes/

scripts/                  # Código que no pertenece a una escena concreta
└── globales/             # Autoloads (singletons)
```

## Controles (prueba)

| Acción | Tecla |
|---|---|
| Mover / saltar | Flechas + Espacio |
| Volver al menú (en nivel) | ESC |
| Detener juego (en editor) | F8 (con el editor enfocado) |
