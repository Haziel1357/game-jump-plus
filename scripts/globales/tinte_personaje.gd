extends RefCounted

# Utilidad compartida para pintar los modelos 3D con el color del personaje.
# La usan la selección de jugador y el nivel (la isla), así el coloreado
# temporal es el mismo en ambas pantallas. Se importa con preload() desde
# quien la use:
#   const TintePersonaje := preload("res://scripts/globales/tinte_personaje.gd")
#
# Nota: es temporal. Cuando los artistas dejen los modelos ya coloreados,
# basta con dejar de llamar a aplicar() para que se vea el arte definitivo.


## Recorre el árbol y pone 'color' en el albedo de todos los materiales.
## Cada material se duplica antes de tocarlo: así dos modelos del mismo
## archivo pueden llevar colores distintos a la vez en la misma escena.
static func aplicar(nodo: Node, color: Color) -> void:
	if nodo is MeshInstance3D:
		var mesh_instance := nodo as MeshInstance3D
		for i in mesh_instance.get_surface_override_material_count():
			var mat_original: Material = mesh_instance.get_surface_override_material(i)
			if mat_original == null and mesh_instance.mesh:
				mat_original = mesh_instance.mesh.surface_get_material(i)
			if mat_original is BaseMaterial3D:
				var mat: BaseMaterial3D = (mat_original as BaseMaterial3D).duplicate()
				mat.albedo_color = color
				mesh_instance.set_surface_override_material(i, mat)

	for hijo in nodo.get_children():
		aplicar(hijo, color)
