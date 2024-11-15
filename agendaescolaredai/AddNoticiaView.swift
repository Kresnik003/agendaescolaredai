//
//  AddNoticiaView.swift
//  agendaescolaredai
//
//  Created by Juan Antonio Sánchez Carrillo on 19/11/24.
//

import SwiftUI

/// Vista para añadir una nueva noticia al sistema.
/// Permite al usuario crear una noticia proporcionando un título y un contenido.
/// La noticia se guarda en la base de datos de Core Data asociada al usuario actual.
struct AddNoticiaView: View {
    // Inyección del contexto de Core Data desde el entorno de SwiftUI.
    // Esto permite guardar y gestionar entidades en la base de datos.
    @Environment(\.managedObjectContext) private var context

    // Permite cerrar la vista actual cuando la operación de guardar o cancelar se complete.
    @Environment(\.dismiss) private var dismiss

    // Usuario actualmente autenticado que crea la noticia.
    let usuarioActual: Usuario

    // Estados que almacenan los datos introducidos por el usuario.
    @State private var titulo: String = "" // Título de la noticia.
    @State private var contenido: String = "" // Contenido detallado de la noticia.

    /// Cuerpo principal de la vista.
    var body: some View {
        // Contenedor de navegación que organiza el diseño principal.
        NavigationView {
            // Formulario para capturar los datos necesarios para crear una noticia.
            Form {
                // SECCIÓN: Título de la noticia.
                Section(header: Text("Título")) {
                    // Campo de texto para introducir el título.
                    TextField("Introduce el título de la noticia", text: $titulo)
                        .autocapitalization(.sentences) // Capitaliza automáticamente el inicio de las frases.
                        .disableAutocorrection(false) // Permite la corrección automática mientras se escribe.
                        .accessibilityIdentifier("tituloTextField") // Identificador único para pruebas de accesibilidad.
                }

                // SECCIÓN: Contenido de la noticia.
                Section(header: Text("Contenido")) {
                    // Editor de texto para ingresar el contenido principal de la noticia.
                    TextEditor(text: $contenido)
                        .frame(height: 200) // Altura fija para el editor de texto.
                        .accessibilityIdentifier("contenidoTextEditor") // Identificador único para accesibilidad.
                }
            }
            .navigationTitle("Nueva Noticia") // Establece el título de la pantalla en la barra de navegación.
            .toolbar {
                // BOTÓN: Guardar noticia.
                ToolbarItem(placement: .confirmationAction) {
                    // Botón que guarda la noticia al ser presionado.
                    Button("Guardar") {
                        saveNoticia() // Llama a la función que guarda la noticia en Core Data.
                    }
                    .accessibilityIdentifier("guardarNoticiaButton") // Identificador para pruebas de accesibilidad.
                }

                // BOTÓN: Cancelar creación.
                ToolbarItem(placement: .cancellationAction) {
                    // Botón que cierra la vista sin guardar.
                    Button("Cancelar") {
                        dismiss() // Cierra la vista actual.
                    }
                    .accessibilityIdentifier("cancelarNoticiaButton") // Identificador para pruebas de accesibilidad.
                }
            }
        }
    }

    /// Guarda la noticia en la base de datos de Core Data.
    /// Valida que el título y el contenido no estén vacíos antes de proceder.
    private func saveNoticia() {
        // Verifica que tanto el título como el contenido tengan datos válidos.
        guard !titulo.isEmpty, !contenido.isEmpty else {
            print("El título y el contenido no pueden estar vacíos.") // Mensaje de error si algún campo está vacío.
            return
        }

        // Crea una nueva entidad `Noticia` en el contexto actual.
        let noticia = Noticia(context: context)
        noticia.id = UUID() // Asigna un identificador único para la noticia.
        noticia.titulo = titulo // Establece el título ingresado por el usuario.
        noticia.contenido = contenido // Establece el contenido ingresado por el usuario.
        noticia.fechaPublicacion = Date() // Asigna la fecha de publicación como la fecha actual.
        noticia.autor = usuarioActual // Relaciona la noticia con el usuario actual como autor.

        // Intenta guardar los cambios realizados en el contexto.
        do {
            try context.save() // Guarda la nueva noticia en la base de datos.
            dismiss() // Cierra la vista actual después de guardar.
        } catch {
            // Maneja cualquier error que ocurra al guardar.
            print("Error al guardar la noticia: \(error.localizedDescription)")
        }
    }
}
