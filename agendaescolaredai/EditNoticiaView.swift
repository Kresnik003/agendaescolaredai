//
//  EditNoticiaView.swift
//  agendaescolaredai
//
//  Created by Juan Antonio Sánchez Carrillo on 23/11/24.
//

import SwiftUI

/// Vista para editar una noticia existente, permitiendo modificar su título y contenido.
/// Utiliza un formulario para actualizar los detalles y guardar los cambios en Core Data.
struct EditNoticiaView: View {
    // MARK: - Entornos

    @Environment(\.managedObjectContext) private var context // Contexto de Core Data para manejar la persistencia.
    @Environment(\.dismiss) private var dismiss // Control para cerrar la vista actual.

    // MARK: - Propiedades

    let noticia: Noticia // Noticia que se está editando.

    // MARK: - Estados locales

    /// Estados para almacenar temporalmente los valores editables de la noticia.
    @State private var titulo: String // Título de la noticia.
    @State private var contenido: String // Contenido de la noticia.

    // MARK: - Inicializador

    /// Configura los valores iniciales de los estados basándose en los datos de la noticia proporcionada.
    /// - Parameter noticia: La noticia que se va a editar.
    init(noticia: Noticia) {
        self.noticia = noticia
        _titulo = State(initialValue: noticia.titulo ?? "") // Inicializa el estado del título.
        _contenido = State(initialValue: noticia.contenido ?? "") // Inicializa el estado del contenido.
    }

    // MARK: - Vista principal

    var body: some View {
        // Vista principal organizada en un formulario.
        NavigationView {
            Form {
                // Sección para editar el título de la noticia.
                Section(header: Text("Título de la Noticia")
                    .accessibilityIdentifier("editNoticiaTituloHeader")) { // Identificador de accesibilidad para pruebas automatizadas.
                    TextField("Título", text: $titulo) // Campo de texto editable para el título.
                        .autocapitalization(.sentences) // Capitaliza automáticamente las oraciones al escribir.
                        .accessibilityIdentifier("editNoticiaTituloField") // Identificador de accesibilidad.
                }

                // Sección para editar el contenido de la noticia.
                Section(header: Text("Contenido")
                    .accessibilityIdentifier("editNoticiaContenidoHeader")) { // Encabezado con identificador de accesibilidad.
                    TextEditor(text: $contenido) // Editor de texto para el contenido de la noticia.
                        .frame(height: 200) // Define una altura específica para el editor.
                        .accessibilityIdentifier("editNoticiaContenidoEditor") // Identificador de accesibilidad.
                }
            }
            .navigationTitle("Editar Noticia") // Título que aparece en la barra de navegación.
            .accessibilityIdentifier("editNoticiaTitle") // Identificador de accesibilidad para toda la vista.
            .toolbar {
                // Botón para guardar los cambios realizados.
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        saveChanges() // Llama a la función para guardar los cambios.
                    }
                    .accessibilityIdentifier("editNoticiaGuardarButton") // Identificador de accesibilidad para el botón de guardar.
                }

                // Botón para cancelar y cerrar la vista sin guardar.
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss() // Cierra la vista sin guardar cambios.
                    }
                    .accessibilityIdentifier("editNoticiaCancelarButton") // Identificador de accesibilidad para el botón de cancelar.
                }
            }
        }
    }

    // MARK: - Función para guardar cambios

    /// Guarda los cambios realizados en la noticia y los persiste en Core Data.
    private func saveChanges() {
        // Limpia los espacios innecesarios de los valores editados antes de guardarlos.
        noticia.titulo = titulo.trimmingCharacters(in: .whitespacesAndNewlines) // Elimina espacios en blanco en el título.
        noticia.contenido = contenido.trimmingCharacters(in: .whitespacesAndNewlines) // Elimina espacios en blanco en el contenido.
        noticia.fechaPublicacion = Date() // Actualiza la fecha de publicación a la fecha actual.

        // Intenta guardar los cambios en la base de datos.
        do {
            try context.save() // Persiste los cambios en Core Data.
            print("Noticia actualizada correctamente.") // Muestra un mensaje de éxito en la consola.
            dismiss() // Cierra la vista tras guardar los cambios.
        } catch {
            // Manejo de errores en caso de que falle la operación de guardado.
            print("Error al guardar los cambios: \(error.localizedDescription)") // Imprime un mensaje de error en la consola.
        }
    }
}
