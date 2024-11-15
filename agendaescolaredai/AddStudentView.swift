//
//  AddStudentView.swift
//  agendaescolaredai
//
//  Created by Juan Antonio Sánchez Carrillo on 25/11/24.
//

import SwiftUI

/// Vista para añadir un nuevo alumno al sistema.
/// Permite seleccionar un centro, un aula y un tutor.
struct AddStudentView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var nombre: String = "" // Nombre del alumno.
    @State private var fechaNacimiento: Date = Date() // Fecha de nacimiento del alumno.
    @State private var selectedCentroID: UUID? // Identificador del centro seleccionado.
    @State private var selectedAulaID: UUID? // Identificador del aula seleccionada.
    @State private var selectedTutorID: UUID? // Identificador del tutor seleccionado.

    // FetchRequest para obtener los centros disponibles.
    @FetchRequest(
        entity: Centro.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Centro.nombre, ascending: true)]
    ) private var centros: FetchedResults<Centro>

    // FetchRequest para obtener los tutores disponibles.
    @FetchRequest(
        entity: Usuario.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Usuario.nombre, ascending: true)],
        predicate: NSPredicate(format: "rol == %@", "tutor")
    ) private var tutores: FetchedResults<Usuario>

    /// Computed property para filtrar aulas según el centro seleccionado.
    private var aulasFiltradas: [Aula] {
        guard let centroID = selectedCentroID,
              let centroSeleccionado = centros.first(where: { $0.id == centroID }) else { return [] }
        return centroSeleccionado.aulas?.allObjects as? [Aula] ?? []
    }

    var body: some View {
        NavigationView {
            Form {
                // SECCIÓN: Información del alumno.
                Section(header: Text("Información del Alumno")) {
                    TextField("Nombre", text: $nombre)
                        .autocapitalization(.words)
                        .accessibilityIdentifier("studentNameField")

                    DatePicker("Fecha de Nacimiento", selection: $fechaNacimiento, displayedComponents: .date)
                        .environment(\.locale, Locale(identifier: "es_ES"))
                        .accessibilityIdentifier("birthDatePicker")
                }

                // SECCIÓN: Selección del centro.
                Section(header: Text("Centro")) {
                    Picker("Selecciona un Centro", selection: $selectedCentroID) {
                        ForEach(centros, id: \.id) { centro in
                            Text(centro.nombre ?? "Sin Nombre") // Muestra el nombre completo del centro.
                                .lineLimit(1) // Permite que el texto sea visible en una línea.
                        }
                    }
                    .pickerStyle(.menu) // Usa un estilo de menú para el picker.
                    .onChange(of: selectedCentroID) {
                        selectedAulaID = nil // Resetea el aula seleccionada al cambiar el centro.
                    }
                    .accessibilityIdentifier("centroPicker")
                }

                // SECCIÓN: Selección del aula.
                Section(header: Text("Aula")) {
                    if aulasFiltradas.isEmpty {
                        Text("Selecciona un centro primero").foregroundColor(.gray)
                    } else {
                        Picker("Selecciona un Aula", selection: $selectedAulaID) {
                            ForEach(aulasFiltradas, id: \.id) { aula in
                                Text(aula.nombre ?? "Sin Nombre") // Muestra el nombre del aula.
                            }
                        }
                        .pickerStyle(.menu)
                        .accessibilityIdentifier("aulaPicker")
                    }
                }

                // SECCIÓN: Selección del tutor.
                Section(header: Text("Tutor")) {
                    Picker("Selecciona un Tutor", selection: $selectedTutorID) {
                        ForEach(tutores, id: \.id) { tutor in
                            Text(tutor.nombre ?? "Sin Nombre")
                                .tag(tutor.id) // Usa el UUID del tutor como etiqueta.
                        }
                    }
                    .pickerStyle(.menu)
                    .accessibilityIdentifier("tutorPicker")
                }
            }
            .navigationTitle("Nuevo Alumno")
            .toolbar {
                // BOTÓN: Guardar alumno.
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        saveStudent()
                    }
                    .disabled(selectedCentroID == nil || selectedAulaID == nil || nombre.isEmpty) // Valida los datos.
                    .accessibilityIdentifier("saveStudentButton")
                }

                // BOTÓN: Cancelar.
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .accessibilityIdentifier("cancelButton")
                }
            }
        }
    }

    /// Guarda un nuevo alumno en Core Data.
    private func saveStudent() {
        // Busca el centro, aula y tutor seleccionados.
        guard let aulaSeleccionada = aulasFiltradas.first(where: { $0.id == selectedAulaID }),
              let tutorSeleccionado = tutores.first(where: { $0.id == selectedTutorID }) else { return }

        let newStudent = Alumno(context: context)
        newStudent.id = UUID()
        newStudent.nombre = nombre
        newStudent.fechaNacimiento = fechaNacimiento
        newStudent.aula = aulaSeleccionada
        newStudent.tutor = tutorSeleccionado

        do {
            try context.save()
            dismiss()
        } catch {
            print("Error al guardar el alumno: \(error.localizedDescription)")
        }
    }
}
