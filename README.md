mi-juego/
├── CLAUDE.md
├── project.godot
├── .gitignore
│
├── escenas/                  # Todo lo que es "una cosa" del juego
│   ├── jugador/
│   │   ├── jugador.tscn
│   │   ├── jugador.gd
│   │   └── modelo/
│   │       ├── jugador.blend
│   │       └── jugador_textura_color.png
│   ├── enemigos/
│   │   └── slime/
│   │       ├── slime.tscn
│   │       └── slime.gd
│   ├── objetos/              # Monedas, cofres, puertas, etc.
│   │   └── moneda/
│   │       ├── moneda.tscn
│   │       └── moneda.gd
│   └── niveles/
│       ├── nivel_01/
│       │   └── nivel_01.tscn
│       └── mundo_pruebas/
│           └── mundo_pruebas.tscn
│
├── interfaz/                 # Menús y HUD
│   ├── menu_principal/
│   │   ├── menu_principal.tscn
│   │   └── menu_principal.gd
│   └── hud/
│       ├── hud.tscn
│       └── hud.gd
│
├── recursos/                 # Assets compartidos entre varias escenas
│   ├── materiales/
│   ├── texturas/
│   ├── modelos/              # Modelos de escenario: árboles, rocas, casas
│   ├── audio/
│   │   ├── musica/
│   │   └── efectos/
│   └── fuentes/
│
├── scripts/                  # Código que no pertenece a una escena concreta
│   └── globales/             # Autoloads (singletons): datos del juego, sonido...
│       └── estado_juego.gd
│
└── addons/                   # Plugins de terceros (Godot la exige con este nombre)
