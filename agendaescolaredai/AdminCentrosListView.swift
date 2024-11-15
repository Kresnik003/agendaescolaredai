//
//  AdminCentrosListView.swift
//  agendaescolaredai
//
//  Created by Juan Antonio Sánchez Carrillo on 22/11/24.
//

import SwiftUI
import CoreData

/// Vista principal para que los administradores gestionen los centros educativos.
/// Esta vista permite buscar, agregar, editar y eliminar centros, manteniendo los datos sincronizados
/// con Core Data gracias a la integración de `@FetchRequest`.
struct AdminCentrosListView: View {
    // MARK: - Propiedades

    @Environment(\.managedObjectContext) private var context // Contexto de Core Data para realizar operaciones CRUD.
    @State private var searchText: String = "" // Almacena el texto ingresado en la barra de búsqueda.
    @State private var isAddingCentro: Bool = false // Controla la presentación de la hoja para agregar centros.
    @State private var selectedCentro: Centro? // Almacena el centro seleccionado para edición.

    // FetchRequest que obtiene los datos de Core Data y los actualiza automáticamente al detectar cambios.
    @FetchRequest(
        entity: Centro.entity(), // Especifica la entidad de Core Data a consultar.
        sortDescriptors: [NSSortDescriptor(keyPath: \Centro.nombre, ascending: true)] // Ordena por nombre ascendente.
    ) private var centros: FetchedResults<Centro>

    // MARK: - Cuerpo de la Vista

    var body: some View {
        NavigationView {
            VStack {
                // Barra de búsqueda para filtrar los centros por nombre.
                TextField("Buscar centro...", text: $searchText)
                    .padding(10) // Espaciado interno.
                    .background(Color(.systemGray6)) // Fondo gris claro.
                    .cornerRadius(8) // Bordes redondeados.
                    .padding(.horizontal) // Espaciado lateral.
                    .accessibilityIdentifier("buscarCentroTextField") // Identificador para pruebas de accesibilidad.

                // Lista de centros filtrados según el texto de búsqueda.
                List {
                    // Itera sobre los centros filtrados y muestra una fila para cada uno.
                    ForEach(filteredCentros, id: \.id) { centro in
                        Button(action: {
                            selectedCentro = centro // Asigna el centro seleccionado para editar.
                        }) {
                            HStack {
                                VStack(alignment: .leading) {
                                    // Muestra el nombre del centro.
                                    Text(centro.nombre ?? "Sin Nombre")
                                        .font(.headline)

                                    // Muestra la cantidad de alumnos relacionados.
                                    Text("Alumnos: \(centro.alumnos?.count ?? 0)")
                                        .font(.subheadline)
                                        .foregroundColor(.blue)
                                }
                                Spacer() // Agrega espacio entre el texto y el borde derecho.
                            }
                        }
                        .accessibilityIdentifier("centroRow_\(centro.id?.uuidString ?? "unknown")") // Identificador único por centro.
                    }
                    .onDelete(perform: deleteCentros) // Habilita la eliminación de centros.
                }
                .listStyle(PlainListStyle()) // Estilo de lista simple, sin fondo adicional.
                .accessibilityIdentifier("adminCentrosList") // Identificador para pruebas de accesibilidad.
            }
            .navigationTitle("Gestionar Centros") // Título principal de la vista.
            .toolbar {
                // Botón para agregar un nuevo centro.
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isAddingCentro = true // Muestra la hoja para agregar un centro.
                    }) {
                        Image(systemName: "plus") // Icono de suma.
                            .foregroundColor(.blue) // Color azul para destacar.
                            .accessibilityIdentifier("addCentroButton") // Identificador de accesibilidad.
                    }
                }
            }
            // Presenta una hoja para agregar un nuevo centro.
            .sheet(isPresented: $isAddingCentro) {
                AddCentroView {
                    isAddingCentro = false // Cierra la hoja tras guardar.
                }
            }
            // Presenta una hoja para editar un centro seleccionado.
            .sheet(item: $selectedCentro) { centro in
                EditCentroView(centro: centro)
            }
        }
    }

    // MARK: - Funciones Auxiliares

    /// Filtra los centros según el texto ingresado en la barra de búsqueda.
    private var filteredCentros: [Centro] {
        centros.filter { centro in
            // Muestra todos los centros si el campo de búsqueda está vacío.
            // De lo contrario, filtra los centros cuyo nombre contenga el texto ingresado.
            searchText.isEmpty || centro.nombre?.localizedCaseInsensitiveContains(searchText) == true
        }
    }

    /// Elimina los centros seleccionados de la lista y de Core Data.
    /// - Parameter offsets: Índices de los centros seleccionados para eliminación.
    private func deleteCentros(at offsets: IndexSet) {
        for index in offsets {
            context.delete(centros[index]) // Solicita la eliminación del centro.
        }
        do {
            try context.save() // Guarda los cambios en Core Data.
        } catch {
            print("Error al eliminar los centros: \(error.localizedDescription)")
        }
    }
}
