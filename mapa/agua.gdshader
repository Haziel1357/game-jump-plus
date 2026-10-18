shader_type spatial;

// Colores del mar
uniform vec4 color_profundo : source_color = vec4(0.01, 0.12, 0.42, 0.95);
uniform vec4 color_superficie : source_color = vec4(0.08, 0.48, 0.78, 0.88);
uniform vec4 color_crestas : source_color = vec4(0.40, 0.85, 0.95, 0.6);

// Ajustes de movimiento
uniform float velocidad : hint_range(0.0, 3.0) = 0.8;
uniform float escala_onda : hint_range(1.0, 40.0) = 16.0;
uniform float fuerza_deformacion : hint_range(0.0, 1.0) = 0.4;

// Función de ruido rápida para turbulencia orgánica
float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float ruido(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x),
	           mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), f.x), f.y);
}

void fragment() {
	// 1. Coordenadas animadas cruzadas en 3 direcciones
	vec2 uv1 = UV * escala_onda + vec2(TIME * velocidad * 0.5, TIME * velocidad * 0.2);
	vec2 uv2 = UV * (escala_onda * 1.2) - vec2(TIME * velocidad * 0.4, TIME * velocidad * 0.6);
	vec2 uv3 = UV * (escala_onda * 0.8) + vec2(-TIME * velocidad * 0.3, TIME * velocidad * 0.4);

	// 2. Ondas principales y turbulencia de choque
	float o1 = sin(uv1.x + uv1.y + ruido(uv1));
	float o2 = cos(uv2.x - uv2.y * 1.3 + ruido(uv2));
	float o3 = sin(uv3.x * 1.4 + uv3.y);

	// Combinación de choques entre olas
	float onda_final = (o1 + o2 + o3) / 3.0 * 0.5 + 0.5;
	float crestas = smoothstep(0.6, 0.85, (o1 * o2) * 0.5 + 0.5);

	// 3. Mezcla de color
	vec4 color_base = mix(color_profundo, color_superficie, onda_final);
	vec4 color_resultado = mix(color_base, color_crestas, crestas * fuerza_deformacion);

	// 4. Alteración de NORMALES para crear relieve de olas dinámicas
	vec3 normal_mar = vec3(
		(cos(uv1.x * 2.0 + TIME * velocidad) + sin(uv2.x)) * fuerza_deformacion,
		1.0,
		(sin(uv1.y * 2.0 + TIME * velocidad) + cos(uv3.y)) * fuerza_deformacion
	);

	ALBEDO = color_resultado.rgb;
	ALPHA = color_resultado.a;
	NORMAL = normalize(normal_mar);
	ROUGHNESS = 0.05;
	SPECULAR = 0.6;
}