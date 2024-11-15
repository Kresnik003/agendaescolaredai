//
//  AddCentroView.swift
//  agendaescolaredai
//
//  Created by Juan Antonio Sánchez Carrillo on 22/11/24.
//

import SwiftUI
import CoreData

/// Vista que permite agregar un nuevo centro educativo al sistema.
/// Captura información relevante como nombre, descripción, teléfono y ubicación,
/// almacenando los datos en Core Data.
struct AddCentroView: View {
    @Environment(\.managedObjectContext) private var context // Contexto para manejar Core Data.
    @Environment(\.dismiss) private var dismiss // Permite cerrar la vista tras completar la acción.
    
    // Variables de estado para almacenar temporalmente los datos ingresados.
    @State private var nombre: String = "" // Nombre del centro.
    @State private var descripcion: String = "" // Descripción del centro.
    @State private var telefono: String = "" // Teléfono del centro.
    @State private var ubicacion: String = "" // Ubicación física del centro.
    
    // Callback para notificar que los datos han sido actualizados.
    let onSave: () -> Void

    var body: some View {
        NavigationView {
            Form {
                // SECCIÓN: Información básica del centro.
                Section(header: Text("Información del Centro")) {
                    // Campo de texto para el nombre del centro.
                    TextField("Nombre del Centro", text: $nombre)
                        .accessibilityIdentifier("nombreCentroTextField")
                    
                    // Campo de texto para la descripción del centro.
                    TextField("Descripción", text: $descripcion)
                        .accessibilityIdentifier("descripcionCentroTextField")
                    
                    // Campo de texto para el teléfono del centro.
                    TextField("Teléfono", text: $telefono)
                        .keyboardType(.phonePad) // Usa un teclado numérico.
                        .accessibilityIdentifier("telefonoCentroTextField")
                    
                    // Campo de texto para la ubicación del centro.
                    TextField("Ubicación", text: $ubicacion)
                        .accessibilityIdentifier("ubicacionCentroTextField")
                }
            }
            .navigationTitle("Agregar Centro") // Título de la vista.
            .toolbar {
                // BOTÓN: Guardar el nuevo centro.
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        saveCentro() // Llama a la función para guardar el centro.
                    }
                    .accessibilityIdentifier("guardarCentroButton")
                }
                // BOTÓN: Cancelar y cerrar la vista.
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss() // Cierra la vista sin guardar.
                    }
                    .accessibilityIdentifier("cancelarCentroButton")
                }
            }
        }
    }
    
    /// Función que guarda el centro en Core Data.
    private func saveCentro() {
        // Validación básica: verifica que los campos requeridos estén llenos.
        guard !nombre.isEmpty, !descripcion.isEmpty, !ubicacion.isEmpty else {
            print("Error: Todos los campos son obligatorios.")
            return
        }
        
        // Crea un nuevo objeto `Centro` en Core Data.
        let newCentro = Centro(context: context)
        newCentro.id = UUID() // Genera un identificador único.
        newCentro.nombre = nombre
        newCentro.descripcion = descripcion
        newCentro.telefono = telefono
        newCentro.ubicacion = ubicacion
        
        // Intenta guardar el contexto y actualiza la lista si tiene éxito.
        do {
            try context.save() // Persiste los cambios en Core Data.
            onSave() // Notifica que los datos han cambiado.
            dismiss() // Cierra la vista tras guardar.
        } catch {
            print("Error al guardar el centro: \(error.localizedDescription)")
        }
    }
}
