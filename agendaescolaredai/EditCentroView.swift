//
//  EditCentroView.swift
//  agendaescolaredai
//
//  Created by Juan Antonio Sánchez Carrillo on 22/11/24.
//

import SwiftUI
import CoreData

/// Vista para editar los detalles de un centro existente.
/// Permite actualizar información básica como nombre, dirección, teléfono y descripción.
struct EditCentroView: View {
    // MARK: - Entornos

    @Environment(\.managedObjectContext) private var context // Contexto de Core Data para interactuar con la base de datos.
    @Environment(\.dismiss) private var dismiss // Permite cerrar la vista actual en la pila de navegación.

    // MARK: - Variables de Estado

    @State private var nombre: String // Nombre del centro.
    @State private var ubicacion: String // Dirección del centro.
    @State private var telefono: String // Teléfono del centro.
    @State private var descripcion: String // Descripción del centro.

    let centro: Centro // Objeto `Centro` que se está editando.

    // MARK: - Inicialización

    /// Inicializa la vista con un centro específico y configura sus valores iniciales.
    /// - Parameter centro: Instancia del centro a editar.
    init(centro: Centro) {
        self.centro = centro
        _nombre = State(initialValue: centro.nombre ?? "") // Inicializa el nombre.
        _ubicacion = State(initialValue: centro.ubicacion ?? "") // Inicializa la ubicación.
        _telefono = State(initialValue: centro.telefono ?? "") // Inicializa el teléfono.
        _descripcion = State(initialValue: centro.descripcion ?? "") // Inicializa la descripción.
    }

    // MARK: - Cuerpo de la Vista

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Detalles del Centro")) {
                    // Campo de texto para editar el nombre.
                    TextField("Nombre", text: $nombre)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .accessibilityIdentifier("editCentroNombreField")

                    // Campo de texto para editar la dirección.
                    TextField("Dirección", text: $ubicacion)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .accessibilityIdentifier("editCentroDireccionField")

                    // Campo de texto para editar el teléfono.
                    TextField("Teléfono", text: $telefono)
                        .keyboardType(.phonePad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .accessibilityIdentifier("editCentroTelefonoField")

                    // Editor de texto para editar la descripción.
                    TextEditor(text: $descripcion)
                        .frame(height: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3))
                        )
                        .accessibilityIdentifier("editCentroDescripcionField")
                }
            }
            .navigationTitle("Editar Centro")
            .toolbar {
                // Botón para cancelar los cambios.
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss() // Cierra la vista sin guardar cambios.
                    }
                    .accessibilityIdentifier("editCentroCancelarButton")
                }
                // Botón para guardar los cambios.
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        saveChanges() // Guarda los cambios realizados.
                    }
                    .accessibilityIdentifier("editCentroGuardarButton")
                }
            }
        }
    }

    // MARK: - Funciones Auxiliares

    /// Guarda los cambios realizados en los detalles del centro.
    private func saveChanges() {
        centro.nombre = nombre.trimmingCharacters(in: .whitespacesAndNewlines)
        centro.ubicacion = ubicacion.trimmingCharacters(in: .whitespacesAndNewlines)
        centro.telefono = telefono.trimmingCharacters(in: .whitespacesAndNewlines)
        centro.descripcion = descripcion.trimmingCharacters(in: .whitespacesAndNewlines)

        do {
            try context.save() // Guarda los cambios en Core Data.
            dismiss() // Cierra la vista tras guardar.
        } catch {
            print("Error al guardar los cambios del centro: \(error.localizedDescription)")
        }
    }
}
