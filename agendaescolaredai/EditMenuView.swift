//
//  EditMenuView.swift
//  agendaescolaredai
//
//  Created by Juan Antonio Sánchez Carrillo on 22/11/24.
//

import SwiftUI

/// Vista para editar un menú existente.
/// Permite modificar los detalles de un menú como la fecha y los diferentes platos.
struct EditMenuView: View {
    // MARK: - Entornos

    @Environment(\.managedObjectContext) private var context // Contexto de Core Data para manejar persistencia.
    @Environment(\.dismiss) private var dismiss // Controla el cierre de la vista actual.

    // MARK: - Propiedades

    let menu: Menu // Menú que se está editando.
    let onSave: () -> Void // Callback que se ejecuta después de guardar los cambios.

    // MARK: - Estados locales

    /// Estados para almacenar los datos editables del menú.
    @State private var fecha: Date // Fecha del menú.
    @State private var desayuno: String // Detalles del desayuno.
    @State private var tentempie: String // Detalles del tentempié.
    @State private var primerPlato: String // Detalles del primer plato.
    @State private var segundoPlato: String // Detalles del segundo plato.
    @State private var postre: String // Detalles del postre.

    // MARK: - Inicializador

    /// Configura los valores iniciales para los estados a partir de los datos del menú.
    /// - Parameters:
    ///   - menu: Menú que se va a editar.
    ///   - onSave: Closure que se ejecuta al guardar los cambios.
    init(menu: Menu, onSave: @escaping () -> Void) {
        self.menu = menu
        self.onSave = onSave
        // Inicializa los estados locales con los valores actuales del menú.
        _fecha = State(initialValue: menu.fecha ?? Date())
        _desayuno = State(initialValue: menu.desayuno ?? "")
        _tentempie = State(initialValue: menu.tentempie ?? "")
        _primerPlato = State(initialValue: menu.primerPlato ?? "")
        _segundoPlato = State(initialValue: menu.segundoPlato ?? "")
        _postre = State(initialValue: menu.postre ?? "")
    }

    // MARK: - Vista principal

    var body: some View {
        // Formulario para editar los campos del menú.
        Form {
            // Sección para seleccionar la fecha del menú.
            Section(header: Text("Fecha del Menú")) {
                DatePicker("Selecciona la fecha", selection: $fecha, displayedComponents: .date)
                    .environment(\.locale, Locale(identifier: "es_ES")) // Configura el selector de fecha en español.
            }

            // Sección para editar los detalles de los platos del menú.
            Section(header: Text("Detalles del Menú")) {
                // Cada plato es un campo editable.
                menuField("Desayuno", text: $desayuno)
                menuField("Tentempié", text: $tentempie)
                menuField("Primer Plato", text: $primerPlato)
                menuField("Segundo Plato", text: $segundoPlato)
                menuField("Postre", text: $postre)
            }
        }
        .navigationTitle("Editar Menú") // Título de la vista.
        .toolbar {
            // Botón para guardar los cambios.
            ToolbarItem(placement: .confirmationAction) {
                Button("Guardar") {
                    saveChanges() // Llama a la función para guardar los cambios.
                }
            }
            // Botón para cancelar los cambios y cerrar la vista.
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancelar") {
                    dismiss() // Cierra la vista sin guardar cambios.
                }
            }
        }
    }

    // MARK: - Vista auxiliar

    /// Crea un campo de entrada editable para los platos del menú.
    /// - Parameters:
    ///   - title: Título del campo.
    ///   - text: Binding del texto editable.
    /// - Returns: Una vista que representa el campo editable.
    private func menuField(_ title: String, text: Binding<String>) -> some View {
        HStack {
            Text(title) // Etiqueta con el título del campo.
                .frame(width: 120, alignment: .leading) // Alineación y tamaño fijo para el título.
            TextField("Ingresa \(title.lowercased())", text: text) // Campo de entrada para el texto.
                .textFieldStyle(RoundedBorderTextFieldStyle()) // Estilo visual del campo.
        }
    }

    // MARK: - Función para guardar cambios

    /// Guarda los cambios realizados en el menú y actualiza la base de datos.
    private func saveChanges() {
        // Actualiza los valores del menú con los datos editados.
        menu.fecha = fecha
        menu.desayuno = desayuno.trimmingCharacters(in: .whitespacesAndNewlines) // Elimina espacios innecesarios.
        menu.tentempie = tentempie.trimmingCharacters(in: .whitespacesAndNewlines)
        menu.primerPlato = primerPlato.trimmingCharacters(in: .whitespacesAndNewlines)
        menu.segundoPlato = segundoPlato.trimmingCharacters(in: .whitespacesAndNewlines)
        menu.postre = postre.trimmingCharacters(in: .whitespacesAndNewlines)

        do {
            // Intenta guardar los cambios en Core Data.
            try context.save()
            print("Menú guardado correctamente.") // Mensaje de éxito en la consola.
            onSave() // Notifica a la vista principal que se guardaron los cambios.
            dismiss() // Cierra la vista actual tras guardar.
        } catch {
            // Manejo de errores en caso de que falle el guardado.
            print("Error al guardar el menú: \(error.localizedDescription)")
        }
    }
}
