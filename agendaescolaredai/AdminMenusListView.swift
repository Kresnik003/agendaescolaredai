//
//  AdminMenusListView.swift
//  agendaescolaredai
//
//  Created by Juan Antonio Sánchez Carrillo on 22/11/24.
//

import SwiftUI
import CoreData

/// Vista para que el administrador gestione los menús.
struct AdminMenusListView: View {
    @Environment(\.managedObjectContext) private var context // Contexto de Core Data para gestionar datos.
    @State private var searchText: String = "" // Estado para manejar el texto del campo de búsqueda.

    /// FetchRequest para obtener los menús de la base de datos, ordenados por fecha en orden ascendente.
    @FetchRequest(
        entity: Menu.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Menu.fecha, ascending: true)]
    ) private var menus: FetchedResults<Menu>

    @State private var refreshID = UUID() // Identificador único utilizado para forzar la actualización de la lista.

    /// Cuerpo principal de la vista.
    var body: some View {
        NavigationView {
            VStack {
                // Barra de búsqueda para filtrar menús.
                TextField("Buscar menú por fecha...", text: $searchText)
                    .padding(10)
                    .background(Color(.systemGray6)) // Fondo gris claro para el campo.
                    .cornerRadius(8) // Esquinas redondeadas.
                    .padding(.horizontal) // Espaciado horizontal.
                    .accessibilityIdentifier("searchMenuTextField") // Identificador de accesibilidad.

                // Lista de menús disponibles.
                List {
                    // Itera sobre los menús filtrados.
                    ForEach(filteredMenus, id: \.id) { menu in
                        // Cada elemento navega a la vista `EditMenuView` para edición.
                        NavigationLink(
                            destination: EditMenuView(menu: menu, onSave: {
                                refreshID = UUID() // Cambia el identificador para actualizar la lista.
                            })
                        ) {
                            MenuRowView(menu: menu) // Fila personalizada para mostrar información del menú.
                                .accessibilityIdentifier("menuRow_\(menu.id?.uuidString ?? "unknown")") // Identificador único.
                        }
                    }
                    .onDelete(perform: deleteMenus) // Permite eliminar menús mediante la acción de deslizar.
                }
                .id(refreshID) // Usa el identificador único para forzar la regeneración de la lista.
                .listStyle(PlainListStyle()) // Estilo de lista sencillo.
                .accessibilityIdentifier("menuList") // Identificador de accesibilidad para la lista.
            }
            .navigationTitle("Menús") // Título de la pantalla.
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AddMenuView()) { // Navega a la vista para añadir un menú.
                        Image(systemName: "plus")
                            .foregroundColor(.blue) // Ícono azul.
                    }
                    .accessibilityIdentifier("addMenuButton") // Identificador para el botón de añadir.
                }
            }
        }
        .accessibilityIdentifier("adminMenusView") // Identificador principal para la vista.
    }

    /// Filtra los menús en función del texto ingresado en el campo de búsqueda.
    private var filteredMenus: [Menu] {
        if searchText.isEmpty {
            return menus.map { $0 } // Si no hay texto, devuelve todos los menús.
        } else {
            return menus.filter { menu in
                let formattedDate = dateFormatter.string(from: menu.fecha ?? Date()) // Formatea la fecha del menú.
                return formattedDate.contains(searchText) // Comprueba si coincide con el texto de búsqueda.
            }
        }
    }

    /// Elimina los menús seleccionados de la base de datos.
    /// - Parameter offsets: Índices de los elementos a eliminar.
    private func deleteMenus(at offsets: IndexSet) {
        offsets.map { menus[$0] }.forEach(context.delete) // Elimina los menús seleccionados.
        do {
            try context.save() // Guarda los cambios en Core Data.
        } catch {
            print("Error al eliminar menú: \(error.localizedDescription)") // Muestra un error en caso de fallo.
        }
    }
}

/// Vista de fila personalizada para mostrar los detalles de un menú.
struct MenuRowView: View {
    let menu: Menu // Objeto del menú a mostrar.

    /// Cuerpo principal de la fila.
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Muestra la fecha del menú.
            Text(dateFormatter.string(from: menu.fecha ?? Date())) // Formatea y muestra la fecha.
                .font(.headline) // Estilo de fuente principal.
                .padding(.bottom, 5) // Espaciado inferior.
                .accessibilityIdentifier("menuFecha_\(menu.id?.uuidString ?? "unknown")") // Identificador único.

            // Detalles del menú agrupados en filas con íconos y texto.
            HStack(spacing: 10) {
                menuItem(icon: "desayunoIcon", text: menu.desayuno ?? "Sin Desayuno", identifier: "desayuno")
                menuItem(icon: "tentempieIcon", text: menu.tentempie ?? "Sin Tentempié", identifier: "tentempie")
            }

            HStack(spacing: 10) {
                menuItem(icon: "primerPlatoIcon", text: menu.primerPlato ?? "Sin 1° Plato", identifier: "primerPlato")
                menuItem(icon: "segundoPlatoIcon", text: menu.segundoPlato ?? "Sin 2° Plato", identifier: "segundoPlato")
            }

            menuItem(icon: "postreIcon", text: menu.postre ?? "Sin Postre", identifier: "postre")
        }
        .padding(.vertical, 10) // Espaciado vertical.
        .padding(.horizontal, 30) // Espaciado horizontal.
        .background(Color.white) // Fondo blanco.
    }

    /// Vista auxiliar para mostrar un elemento del menú con ícono y texto.
    /// - Parameters:
    ///   - icon: Nombre del recurso gráfico para el ícono.
    ///   - text: Texto descriptivo del elemento.
    ///   - identifier: Prefijo para los identificadores de accesibilidad.
    /// - Returns: Vista de un elemento del menú.
    private func menuItem(icon: String, text: String, identifier: String) -> some View {
        HStack(spacing: 8) {
            Image(icon) // Carga el ícono correspondiente.
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24) // Tamaño del ícono.
                .accessibilityIdentifier("\(identifier)Icon_\(menu.id?.uuidString ?? "unknown")") // Identificador único.
            Text(text) // Muestra el texto del elemento.
                .font(.subheadline) // Fuente secundaria.
                .accessibilityIdentifier("\(identifier)Text_\(menu.id?.uuidString ?? "unknown")") // Identificador único.
        }
    }
}
