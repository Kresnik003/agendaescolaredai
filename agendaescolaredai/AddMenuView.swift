//
//  AddMenuView.swift
//  agendaescolaredai
//
//  Created by Juan Antonio Sánchez Carrillo on 22/11/24.
//

import SwiftUI

/// Vista para añadir un nuevo menú al sistema.
/// Permite al usuario ingresar detalles sobre las comidas del día y guardarlas en Core Data.
/// Se compone de secciones para ingresar la fecha y los diferentes elementos del menú.
struct AddMenuView: View {
    @Environment(\.managedObjectContext) private var context // Contexto de Core Data para operaciones de persistencia.
    @Environment(\.dismiss) private var dismiss // Permite cerrar la vista actual.

    // Variables de estado que controlan los datos introducidos en el formulario.
    @State private var fecha = Date() // Fecha seleccionada para el menú.
    @State private var desayuno: String = "" // Descripción del desayuno.
    @State private var tentempie: String = "" // Descripción del tentempié.
    @State private var primerPlato: String = "" // Descripción del primer plato.
    @State private var segundoPlato: String = "" // Descripción del segundo plato.
    @State private var postre: String = "" // Descripción del postre.

    /// Estructura principal de la vista que organiza los elementos en un formulario.
    var body: some View {
        Form {
            // SECCIÓN: Fecha del Menú.
            Section(header: Text("Fecha del Menú")) {
                // Selector de fecha que permite al usuario elegir la fecha del menú.
                DatePicker("Selecciona la fecha", selection: $fecha, displayedComponents: .date)
                    .environment(\.locale, Locale(identifier: "es_ES")) // Configura el selector con formato regional.
                    .accessibilityIdentifier("fechaMenuDatePicker") // Identificador para pruebas de accesibilidad.
            }

            // SECCIÓN: Detalles del Menú.
            Section(header: Text("Detalles del Menú")) {
                // Campo de texto para ingresar el desayuno.
                TextField("Desayuno", text: $desayuno)
                    .accessibilityIdentifier("desayunoTextField") // Identificador para pruebas de accesibilidad.

                // Campo de texto para ingresar el tentempié.
                TextField("Tentempié", text: $tentempie)
                    .accessibilityIdentifier("tentempieTextField") // Identificador para pruebas de accesibilidad.

                // Campo de texto para ingresar el primer plato.
                TextField("Primer Plato", text: $primerPlato)
                    .accessibilityIdentifier("primerPlatoTextField") // Identificador para pruebas de accesibilidad.

                // Campo de texto para ingresar el segundo plato.
                TextField("Segundo Plato", text: $segundoPlato)
                    .accessibilityIdentifier("segundoPlatoTextField") // Identificador para pruebas de accesibilidad.

                // Campo de texto para ingresar el postre.
                TextField("Postre", text: $postre)
                    .accessibilityIdentifier("postreTextField") // Identificador para pruebas de accesibilidad.
            }
        }
        .navigationTitle("Agregar Menú") // Título de la vista.
        .toolbar {
            // Botón de la barra de herramientas para guardar el menú.
            ToolbarItem(placement: .confirmationAction) {
                Button("Guardar") {
                    saveMenu() // Llama a la función para guardar el menú.
                }
                .accessibilityIdentifier("guardarMenuButton") // Identificador para pruebas de accesibilidad.
            }

            // Botón de la barra de herramientas para cancelar la operación y cerrar la vista.
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancelar") {
                    dismiss() // Cierra la vista sin guardar.
                }
                .accessibilityIdentifier("cancelarMenuButton") // Identificador para pruebas de accesibilidad.
            }
        }
    }

    /// Guarda un nuevo menú en Core Data.
    /// Crea una nueva instancia de `Menu`, asigna los valores introducidos y guarda los cambios en el contexto.
    private func saveMenu() {
        // Crea una nueva entidad `Menu` en el contexto.
        let newMenu = Menu(context: context)
        newMenu.id = UUID() // Asigna un identificador único.
        newMenu.fecha = fecha // Asigna la fecha seleccionada.
        newMenu.desayuno = desayuno // Asigna la descripción del desayuno.
        newMenu.tentempie = tentempie // Asigna la descripción del tentempié.
        newMenu.primerPlato = primerPlato // Asigna la descripción del primer plato.
        newMenu.segundoPlato = segundoPlato // Asigna la descripción del segundo plato.
        newMenu.postre = postre // Asigna la descripción del postre.

        // Intenta guardar los cambios en el contexto de Core Data.
        do {
            try context.save() // Guarda el nuevo menú en el almacenamiento persistente.
            dismiss() // Cierra la vista tras guardar.
        } catch {
            // Muestra un error en caso de que falle el guardado.
            print("Error al guardar el menú: \(error.localizedDescription)")
        }
    }
}
