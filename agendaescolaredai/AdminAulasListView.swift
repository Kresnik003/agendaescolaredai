//
//  AdminAulasListView.swift
//  agendaescolaredai
//
//  Created by Juan Antonio Sánchez Carrillo on 22/11/24.
//

import SwiftUI
import CoreData

/// Vista que lista todas las aulas para que el administrador pueda gestionarlas.
/// Permite buscar aulas, visualizar detalles y realizar operaciones CRUD (crear, eliminar).
struct AdminAulasListView: View {
    // Inyección del contexto de Core Data desde el entorno.
    // Este contexto se utiliza para realizar operaciones CRUD en la base de datos.
    @Environment(\.managedObjectContext) private var context

    // Estado para manejar el texto introducido en la barra de búsqueda.
    @State private var searchText: String = ""

    // Estado para almacenar el aula seleccionada para edición o detalle.
    @State private var selectedAula: Aula?

    // FetchRequest para obtener todas las aulas almacenadas en Core Data, ordenadas por nombre.
    @FetchRequest(
        entity: Aula.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Aula.nombre, ascending: true) // Orden alfabético ascendente por nombre.
        ]
    ) private var aulas: FetchedResults<Aula>

    /// Cuerpo principal de la vista.
    var body: some View {
        // Contenedor de navegación que organiza el contenido.
        NavigationView {
            VStack {
                // Barra de búsqueda para filtrar aulas.
                TextField("Buscar aula...", text: $searchText)
                    .padding(10) // Espaciado interno para el campo de búsqueda.
                    .background(Color(.systemGray6)) // Fondo gris claro.
                    .cornerRadius(8) // Bordes redondeados.
                    .padding(.horizontal) // Espaciado lateral.
                    .accessibilityIdentifier("adminAulasSearchField") // Identificador de accesibilidad para pruebas.

                // Lista que muestra las aulas filtradas.
                List {
                    // Itera sobre las aulas filtradas y crea una fila para cada una.
                    ForEach(filteredAulas, id: \.id) { aula in
                        // Botón que abre la vista de detalles o edición para el aula seleccionada.
                        Button(action: {
                            selectedAula = aula // Almacena el aula seleccionada.
                        }) {
                            // Vista personalizada que muestra la información básica del aula.
                            AulaRowView(aula: aula)
                        }
                        .accessibilityIdentifier("adminAulaRow_\(aula.id?.uuidString ?? "unknown")") // Identificador único.
                    }
                    .onDelete(perform: deleteAulas) // Habilita la eliminación de aulas.
                }
                .listStyle(PlainListStyle()) // Estilo de lista simple, sin fondo adicional.
                .accessibilityIdentifier("adminAulasList") // Identificador de accesibilidad para la lista.
            }
            .navigationTitle("Gestionar Aulas") // Título principal de la vista.
            .toolbar {
                // BOTÓN: Agregar nueva aula.
                ToolbarItem(placement: .navigationBarTrailing) {
                    // Navega a la vista para añadir una nueva aula.
                    NavigationLink(destination: AddAulaView()) {
                        Image(systemName: "plus") // Icono de suma.
                            .foregroundColor(.blue) // Color azul para destacar.
                            .accessibilityIdentifier("addAulaButton") // Identificador de accesibilidad.
                    }
                }
            }
            // Presenta una hoja para mostrar detalles o editar el aula seleccionada.
            .sheet(item: $selectedAula) { aula in
                AulaDetailView(aula: .constant(aula), searchText: $searchText)
                // Alternativamente, se podría presentar `EditAulaView` si fuera necesario:
                // EditAulaView(aula: .constant(aula))
            }
        }
    }

    /// Filtra las aulas basándose en el texto introducido en la barra de búsqueda.
    /// - Returns: Una lista de aulas que coinciden con el texto de búsqueda.
    private var filteredAulas: [Aula] {
        aulas.filter { aula in
            // Retorna todas las aulas si el campo de búsqueda está vacío o aquellas cuyo nombre coincide.
            searchText.isEmpty || aula.nombre?.localizedCaseInsensitiveContains(searchText) == true
        }
    }

    /// Elimina las aulas seleccionadas de Core Data.
    /// - Parameter offsets: Índices de las aulas seleccionadas para eliminación.
    private func deleteAulas(at offsets: IndexSet) {
        // Itera sobre los índices seleccionados y elimina las aulas correspondientes.
        for index in offsets {
            context.delete(aulas[index]) // Solicita la eliminación en el contexto de Core Data.
        }
        // Intenta guardar los cambios tras la eliminación.
        do {
            try context.save() // Guarda los cambios en Core Data.
        } catch {
            // Imprime un mensaje de error en caso de que falle la operación.
            print("Error al eliminar las aulas: \(error.localizedDescription)")
        }
    }
}
