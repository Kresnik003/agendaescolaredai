//
//  AdminNoticiasView.swift
//  agendaescolaredai
//
//  Created by Juan Antonio Sánchez Carrillo on 19/11/24.
//

import SwiftUI
import CoreData

/// Vista para que las administradoras gestionen noticias.
struct AdminNoticiasView: View {
    @Environment(\.managedObjectContext) private var context // Contexto de Core Data para gestionar datos persistentes.
    @FetchRequest(
        entity: Noticia.entity(), // Entidad `Noticia` de Core Data.
        sortDescriptors: [NSSortDescriptor(keyPath: \Noticia.fechaPublicacion, ascending: false)] // Orden descendente por fecha.
    ) var noticias: FetchedResults<Noticia> // Lista de noticias recuperadas desde Core Data.

    @State private var showingAddNoticia = false // Control para mostrar la vista modal de añadir noticias.
    let usuarioActual: Usuario // Usuario actual que está logueado, utilizado como autor de las noticias.

    /// Vista principal de la interfaz.
    var body: some View {
        NavigationView {
            VStack {
                // Lista que muestra todas las noticias.
                List {
                    // Iteración sobre las noticias obtenidas.
                    ForEach(noticias, id: \.id) { noticia in
                        // Cada noticia navega a `EditNoticiaView` al seleccionarla.
                        NavigationLink(destination: EditNoticiaView(noticia: noticia)) {
                            VStack(alignment: .leading, spacing: 10) {
                                // Título de la noticia.
                                Text(noticia.titulo ?? "Sin Título")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                    .accessibilityIdentifier("noticiaTitulo_\(noticia.id?.uuidString ?? "unknown")")

                                // Nombre del autor de la noticia.
                                Text("Publicado por: \(noticia.autor?.nombre ?? "Anónimo")")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .accessibilityIdentifier("noticiaAutor_\(noticia.id?.uuidString ?? "unknown")")

                                // Contenido resumido en 2 líneas.
                                Text(noticia.contenido ?? "Sin Contenido")
                                    .font(.body)
                                    .lineLimit(2)
                                    .accessibilityIdentifier("noticiaContenido_\(noticia.id?.uuidString ?? "unknown")")

                                // Fecha de publicación.
                                Text("Fecha: \(noticia.fechaPublicacion ?? Date(), formatter: dateFormatter)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .accessibilityIdentifier("noticiaFecha_\(noticia.id?.uuidString ?? "unknown")")
                            }
                            .padding(.vertical, 5) // Espaciado vertical entre filas.
                            .accessibilityIdentifier("noticiaRow_\(noticia.id?.uuidString ?? "unknown")")
                        }
                    }
                    .onDelete(perform: deleteNoticias) // Acción para eliminar noticias.
                    .accessibilityIdentifier("noticiaList") // Identificador para la lista.
                }
                .listStyle(PlainListStyle()) // Estilo de lista simple.
                .navigationTitle("Noticias") // Título de la pantalla.
                .accessibilityIdentifier("adminNoticiasView") // Identificador de accesibilidad principal.
                .toolbar {
                    // Botón en la barra de herramientas para añadir una noticia.
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showingAddNoticia = true }) {
                            Image(systemName: "plus") // Ícono de añadir.
                                .foregroundColor(.blue)
                        }
                        .accessibilityIdentifier("addNoticiaButton")
                    }
                }

                Spacer() // Agrega un espacio flexible entre la lista y el botón inferior.

                // Botón alternativo para añadir noticias (ubicado en la parte inferior).
                Button(action: {
                    showingAddNoticia = true
                }) {
                    Text("Añadir Noticia")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity) // Ancho máximo posible.
                        .background(Color.blue) // Fondo azul.
                        .cornerRadius(10) // Bordes redondeados.
                        .padding()
                }
                .accessibilityIdentifier("addNoticiaBottomButton") // Identificador para el botón inferior.
                .sheet(isPresented: $showingAddNoticia) {
                    // Presenta la vista para añadir noticias.
                    AddNoticiaView(usuarioActual: usuarioActual)
                        .environment(\.managedObjectContext, context) // Proporciona el contexto de Core Data.
                        .accessibilityIdentifier("addNoticiaSheet") // Identificador para la hoja modal.
                }
            }
        }
    }

    /// Elimina las noticias seleccionadas del almacenamiento persistente.
    /// - Parameter offsets: Índices de las noticias a eliminar.
    private func deleteNoticias(at offsets: IndexSet) {
        offsets.map { noticias[$0] }.forEach(context.delete) // Elimina las noticias seleccionadas.
        do {
            try context.save() // Guarda los cambios tras la eliminación.
        } catch {
            print("Error al eliminar noticias: \(error.localizedDescription)") // Muestra el error en caso de fallo.
        }
    }
}
