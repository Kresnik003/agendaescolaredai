//
//  AulasListView.swift
//  agendaescolaredai
//
//  Created by Juan Antonio Sánchez Carrillo on 16/11/24.
//

import SwiftUI
import CoreData

/// Vista que lista las aulas asignadas a un profesor específico.
/// Permite al profesor buscar y visualizar detalles de las aulas que tiene asignadas.
struct AulasListView: View {
    @State private var searchText: String = "" // Almacena el texto para realizar búsquedas de aulas.
    let profesor: Usuario // Representa al usuario actual con rol de profesor.

    // FetchRequest para obtener las aulas asignadas al profesor.
    // Configurado dinámicamente mediante el inicializador de la vista.
    @FetchRequest private var aulas: FetchedResults<Aula>

    @State private var selectedAula: Aula? // Almacena el aula seleccionada para mostrar su detalle.

    /// Inicializador que configura el FetchRequest para filtrar las aulas asociadas al profesor.
    /// - Parameter profesor: Usuario con rol de profesor.
    init(profesor: Usuario) {
        self.profesor = profesor // Asigna el usuario actual a la propiedad local.

        // Configura el FetchRequest con un predicado para obtener aulas asignadas al profesor.
        _aulas = FetchRequest(
            entity: Aula.entity(), // Especifica la entidad `Aula` como objetivo del FetchRequest.
            sortDescriptors: [NSSortDescriptor(keyPath: \Aula.nombre, ascending: true)], // Ordena las aulas alfabéticamente por su nombre.
            predicate: NSPredicate(format: "ANY profesores == %@", profesor) // Filtra las aulas donde el profesor actual está asignado.
        )
    }

    var body: some View {
        // Contenedor principal que permite navegación dentro de la vista.
        NavigationView {
            VStack {
                // Campo de texto para la barra de búsqueda.
                TextField("Buscar aula...", text: $searchText)
                    .padding(10) // Agrega espacio interior al campo de texto.
                    .background(Color(.systemGray6)) // Define un fondo gris claro.
                    .cornerRadius(8) // Aplica bordes redondeados.
                    .padding(.horizontal) // Espaciado horizontal externo.
                    .accessibilityIdentifier("searchAulasTextField") // Identificador de accesibilidad.

                // Lista de aulas filtradas según el texto de búsqueda.
                List {
                    ForEach(filteredAulas, id: \.id) { aula in
                        Button(action: {
                            selectedAula = aula // Almacena el aula seleccionada para mostrar su detalle.
                        }) {
                            AulaRowView(aula: aula) // Muestra los detalles básicos del aula en una fila.
                        }
                        .accessibilityIdentifier("aulaRow_\(aula.id?.uuidString ?? "unknown")") // Identificador de accesibilidad único por fila.
                    }
                }
                .listStyle(PlainListStyle()) // Estilo de lista simple.
                .accessibilityIdentifier("aulasListView") // Identificador de accesibilidad para la lista.
            }
            .navigationTitle("Mis Aulas") // Título principal de la vista.
            .sheet(item: $selectedAula) { aula in
                // Muestra una vista de detalle para el aula seleccionada.
                AulaDetailView(aula: .constant(aula), searchText: $searchText)
            }
        }
    }

    /// Computa una lista filtrada de aulas en función del texto de búsqueda.
    /// Si no se ha ingresado texto, devuelve todas las aulas asociadas al profesor.
    private var filteredAulas: [Aula] {
        aulas.filter { aula in
            // Retorna todas las aulas si el texto de búsqueda está vacío.
            // De lo contrario, busca coincidencias insensibles a mayúsculas en el nombre del aula.
            searchText.isEmpty || aula.nombre?.localizedCaseInsensitiveContains(searchText) == true
        }
    }
}
