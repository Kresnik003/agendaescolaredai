//
//  EditDailyRecordView.swift
//  agendaescolaredai
//
//  Created by Juan Antonio Sánchez Carrillo on 16/11/24.
//

import SwiftUI
import CoreData

/// Vista para editar un registro diario existente.
/// Permite modificar datos relacionados con las comidas, inventario, siesta y comentarios de un alumno para un día específico.
struct EditDailyRecordView: View {
    // MARK: - Entornos

    @Environment(\.managedObjectContext) private var context // Contexto de Core Data para guardar cambios.
    @Environment(\.dismiss) private var dismiss // Controla el cierre de la vista actual.

    // MARK: - Estados locales

    /// Variables que reflejan los valores editables del registro diario.
    @State private var desayuno: Bool // Indica si el alumno desayunó.
    @State private var tentempie: Bool // Indica si el alumno tomó tentempié.
    @State private var primerPlato: Bool // Indica si el alumno comió el primer plato.
    @State private var segundoPlato: Bool // Indica si el alumno comió el segundo plato.
    @State private var postre: Bool // Indica si el alumno comió postre.
    @State private var toallitasRestantes: Int16 // Cantidad restante de toallitas.
    @State private var panalesRestantes: Int16 // Cantidad restante de pañales.
    @State private var siesta: Bool // Indica si el alumno realizó la siesta.
    @State private var siestaInicio: Date // Hora de inicio de la siesta.
    @State private var siestaFin: Date // Hora de fin de la siesta.
    @State private var comentarios: String // Comentarios adicionales.

    // MARK: - Propiedades

    /// El registro diario que se está editando.
    let registro: RegistroDiario

    // MARK: - Inicializador

    /// Configura los valores iniciales de los estados a partir del registro diario proporcionado.
    /// - Parameter registro: Instancia del registro diario a editar.
    init(registro: RegistroDiario) {
        self.registro = registro
        _desayuno = State(initialValue: registro.desayuno) // Valor inicial para "desayuno".
        _tentempie = State(initialValue: registro.tentempie) // Valor inicial para "tentempié".
        _primerPlato = State(initialValue: registro.primerPlato) // Valor inicial para "primer plato".
        _segundoPlato = State(initialValue: registro.segundoPlato) // Valor inicial para "segundo plato".
        _postre = State(initialValue: registro.postre) // Valor inicial para "postre".
        _toallitasRestantes = State(initialValue: registro.toallitasRestantes) // Valor inicial para "toallitas restantes".
        _panalesRestantes = State(initialValue: registro.panalesRestantes) // Valor inicial para "pañales restantes".
        _siesta = State(initialValue: registro.siesta) // Valor inicial para "siesta".
        _siestaInicio = State(initialValue: registro.siestaInicio ?? Date()) // Valor inicial para "siesta inicio".
        _siestaFin = State(initialValue: registro.siestaFin ?? Date()) // Valor inicial para "siesta fin".
        _comentarios = State(initialValue: registro.comentarios ?? "") // Valor inicial para "comentarios".
    }

    // MARK: - Vista principal

    var body: some View {
        // Contenedor principal con navegación.
        NavigationView {
            Form { // Diseño basado en formulario.
                // Sección para modificar detalles sobre las comidas.
                Section(header: Text("Detalles del Registro").accessibilityIdentifier("editDailyRecordDetailsHeader")) {
                    Toggle("Desayuno", isOn: $desayuno) // Cambia el estado de "desayuno".
                        .accessibilityIdentifier("editDailyRecordDesayunoToggle")
                    Toggle("Tentempié", isOn: $tentempie) // Cambia el estado de "tentempié".
                        .accessibilityIdentifier("editDailyRecordTentempieToggle")
                    Toggle("1° Plato", isOn: $primerPlato) // Cambia el estado de "primer plato".
                        .accessibilityIdentifier("editDailyRecordPrimerPlatoToggle")
                    Toggle("2° Plato", isOn: $segundoPlato) // Cambia el estado de "segundo plato".
                        .accessibilityIdentifier("editDailyRecordSegundoPlatoToggle")
                    Toggle("Postre", isOn: $postre) // Cambia el estado de "postre".
                        .accessibilityIdentifier("editDailyRecordPostreToggle")
                }

                // Sección para modificar el inventario.
                Section(header: Text("Inventario").accessibilityIdentifier("editDailyRecordInventarioHeader")) {
                    Stepper("Toallitas Restantes: \(toallitasRestantes)%", value: $toallitasRestantes, in: 0...100, step: 5) // Ajusta la cantidad de toallitas restantes.
                        .accessibilityIdentifier("editDailyRecordToallitasStepper")
                    Stepper("Pañales Restantes: \(panalesRestantes)%", value: $panalesRestantes, in: 0...100, step: 5) // Ajusta la cantidad de pañales restantes.
                        .accessibilityIdentifier("editDailyRecordPanalesStepper")
                }

                // Sección para modificar detalles sobre la siesta.
                Section(header: Text("Siesta").accessibilityIdentifier("editDailyRecordSiestaHeader")) {
                    Toggle("¿Realizó siesta?", isOn: $siesta) // Activa o desactiva la siesta.
                        .accessibilityIdentifier("editDailyRecordSiestaToggle")
                    if siesta {
                        // Selección de hora de inicio de la siesta.
                        DatePicker("Inicio", selection: $siestaInicio, displayedComponents: .hourAndMinute)
                            .accessibilityIdentifier("editDailyRecordSiestaInicio")
                        // Selección de hora de fin de la siesta.
                        DatePicker("Fin", selection: $siestaFin, displayedComponents: .hourAndMinute)
                            .accessibilityIdentifier("editDailyRecordSiestaFin")
                    }
                }

                // Sección para añadir comentarios.
                Section(header: Text("Comentarios").accessibilityIdentifier("editDailyRecordComentariosHeader")) {
                    TextEditor(text: $comentarios) // Campo de texto libre.
                        .frame(height: 100)
                        .padding(4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        .accessibilityIdentifier("editDailyRecordComentariosTextEditor")
                }
            }
            .navigationTitle("Editar Registro") // Título de la vista.
            .accessibilityIdentifier("editDailyRecordTitle") // Identificador para accesibilidad y pruebas.
            .toolbar { // Barra de herramientas para navegación.
                // Botón para guardar cambios.
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        saveChanges() // Llama a la función que guarda los cambios.
                    }
                    .accessibilityIdentifier("editDailyRecordGuardarButton")
                }
                // Botón para cancelar cambios y cerrar la vista.
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss() // Cierra la vista sin guardar cambios.
                    }
                    .accessibilityIdentifier("editDailyRecordCancelarButton")
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Asegura un comportamiento consistente en la navegación.
    }

    // MARK: - Función para guardar cambios

    /// Guarda los cambios realizados en el registro diario en la base de datos de Core Data.
    private func saveChanges() {
        // Asigna los valores editados al registro diario.
        registro.desayuno = desayuno
        registro.tentempie = tentempie
        registro.primerPlato = primerPlato
        registro.segundoPlato = segundoPlato
        registro.postre = postre
        registro.toallitasRestantes = toallitasRestantes
        registro.panalesRestantes = panalesRestantes
        registro.siesta = siesta
        registro.siestaInicio = siesta ? siestaInicio : nil
        registro.siestaFin = siesta ? siestaFin : nil
        registro.comentarios = comentarios

        do {
            // Intenta guardar los cambios en el contexto de Core Data.
            try context.save()
            print("Registro diario actualizado correctamente.") // Mensaje de éxito en consola.
            dismiss() // Cierra la vista tras guardar exitosamente.
        } catch {
            // Manejo de errores en caso de que falle el guardado.
            print("Error al actualizar el registro diario: \(error.localizedDescription)")
        }
    }
}
