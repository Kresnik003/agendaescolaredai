//
//  AddDailyRecordView.swift
//  agendaescolaredai
//
//  Created by Juan Antonio Sánchez Carrillo on 16/11/24.
//

import SwiftUI
import CoreData

/// Vista para agregar y eliminar registros diarios asociados a alumnos.
/// Esta vista permite al usuario seleccionar un alumno, registrar información diaria relacionada
/// con la alimentación, el inventario, la siesta y comentarios, y gestionar registros existentes mediante la eliminación de los mismos.
struct AddDailyRecordView: View {
    @Environment(\.managedObjectContext) private var context // Contexto de Core Data para persistencia de datos.
    @Environment(\.dismiss) private var dismiss // Permite cerrar la vista actual.

    // Estados para controlar las interacciones y datos temporales en la vista.
    @State private var searchQuery: String = "" // Consulta para buscar alumnos por nombre.
    @State private var filteredAlumnos: [Alumno] = [] // Alumnos filtrados por el término de búsqueda.
    @State private var selectedAlumno: Alumno? // Alumno seleccionado para el registro.
    @State private var fecha = Date() // Fecha del registro diario.
    @State private var desayuno = false // Indica si se ha registrado desayuno.
    @State private var tentempie = false // Indica si se ha registrado tentempié.
    @State private var primerPlato = false // Indica si se ha registrado el primer plato.
    @State private var segundoPlato = false // Indica si se ha registrado el segundo plato.
    @State private var postre = false // Indica si se ha registrado postre.
    @State private var toallitasRestantes = 100 // Porcentaje de toallitas restantes.
    @State private var panalesRestantes = 100 // Porcentaje de pañales restantes.
    @State private var siesta = false // Indica si el alumno realizó siesta.
    @State private var siestaInicio = Date() // Hora de inicio de la siesta.
    @State private var siestaFin = Date() // Hora de fin de la siesta.
    @State private var comentarios = "" // Comentarios adicionales sobre el registro.

    @FetchRequest(
        entity: RegistroDiario.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \RegistroDiario.fecha, ascending: false)]
    ) var registros: FetchedResults<RegistroDiario> // Registros diarios existentes, ordenados por fecha descendente.

    @FetchRequest(
        entity: Alumno.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Alumno.nombre, ascending: true)]
    ) var alumnos: FetchedResults<Alumno> // Lista de alumnos ordenada alfabéticamente.

    var body: some View {
        NavigationView {
            VStack {
                // Formulario principal que contiene todas las secciones.
                Form {
                    // SECCIÓN: Seleccionar un alumno.
                    Section(header: Text("Seleccionar Alumno")) {
                        // Campo de búsqueda para filtrar alumnos por nombre.
                        TextField("Buscar alumno por nombre", text: $searchQuery)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .accessibilityIdentifier("buscarAlumnoTextField")
                            .onChange(of: searchQuery) {
                                filterAlumnos() // Actualiza la lista filtrada al cambiar la consulta.
                            }

                        // Lista de alumnos filtrados, si hay resultados.
                        if !filteredAlumnos.isEmpty {
                            ForEach(filteredAlumnos, id: \.id) { alumno in
                                Button(action: {
                                    selectedAlumno = alumno // Selecciona el alumno.
                                    searchQuery = "" // Limpia la consulta de búsqueda.
                                    filteredAlumnos = [] // Vacía la lista filtrada.
                                }) {
                                    HStack {
                                        // Imagen del alumno si está disponible.
                                        if let imageName = alumno.imagen, let uiImage = loadImage(named: imageName) {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 50, height: 50)
                                                .cornerRadius(12)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(Color(hex: "#7BB2E0"), lineWidth: 2)
                                                )
                                                .accessibilityIdentifier("imagenAlumno_\(alumno.id?.uuidString ?? "")")
                                        } else {
                                            // Imagen de marcador de posición.
                                            Image("placeHolder")
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 50, height: 50)
                                                .cornerRadius(12)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(Color(hex: "#7BB2E0"), lineWidth: 2)
                                                )
                                                .accessibilityIdentifier("imagenAlumnoPlaceHolder")
                                        }
                                        // Nombre del alumno.
                                        Text(alumno.nombre ?? "Sin Nombre")
                                            .font(.headline)
                                            .accessibilityIdentifier("nombreAlumno_\(alumno.id?.uuidString ?? "")")
                                    }
                                }
                                .accessibilityIdentifier("seleccionarAlumnoButton_\(alumno.id?.uuidString ?? "")")
                            }
                        }
                    }

                    // SECCIÓN: Información del alumno seleccionado.
                    if let alumno = selectedAlumno {
                        Section(header: Text("Información del Alumno")) {
                            HStack {
                                // Imagen del alumno seleccionado.
                                if let imageName = alumno.imagen, let uiImage = loadImage(named: imageName) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 80, height: 80)
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color(hex: "#7BB2E0"), lineWidth: 3)
                                        )
                                        .accessibilityIdentifier("imagenAlumnoSeleccionado")
                                } else {
                                    Image("placeHolder")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 80, height: 80)
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color(hex: "#7BB2E0"), lineWidth: 3)
                                        )
                                        .accessibilityIdentifier("imagenAlumnoPlaceHolderSeleccionado")
                                }
                                VStack(alignment: .leading) {
                                    // Nombre del alumno seleccionado.
                                    Text(alumno.nombre ?? "Sin Nombre")
                                        .font(.headline)
                                        .accessibilityIdentifier("nombreAlumnoSeleccionado")
                                    // Curso del aula al que pertenece el alumno.
                                    Text("Curso: \(alumno.aula?.curso ?? "Sin Curso")")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .accessibilityIdentifier("cursoAlumnoSeleccionado")
                                }
                            }
                        }

                        // SECCIÓN: Selección de la fecha del registro.
                        Section(header: Text("Seleccionar Fecha")) {
                            DatePicker("Fecha del Registro", selection: $fecha, displayedComponents: .date)
                                .environment(\.locale, Locale(identifier: "es_ES"))
                                .datePickerStyle(GraphicalDatePickerStyle())
                                .accessibilityIdentifier("fechaRegistroPicker")
                        }

                        // SECCIÓN: Detalles del registro diario.
                        Section(header: Text("Detalles del Registro")) {
                            Toggle("Desayuno", isOn: $desayuno)
                                .accessibilityIdentifier("toggleDesayuno")
                            Toggle("Tentempié", isOn: $tentempie)
                                .accessibilityIdentifier("toggleTentempie")
                            Toggle("1° Plato", isOn: $primerPlato)
                                .accessibilityIdentifier("togglePrimerPlato")
                            Toggle("2° Plato", isOn: $segundoPlato)
                                .accessibilityIdentifier("toggleSegundoPlato")
                            Toggle("Postre", isOn: $postre)
                                .accessibilityIdentifier("togglePostre")
                        }

                        // SECCIÓN: Inventario restante.
                        Section(header: Text("Inventario")) {
                            Stepper("Toallitas Restantes: \(toallitasRestantes)%", value: $toallitasRestantes, in: 0...100, step: 5)
                                .accessibilityIdentifier("stepperToallitasRestantes")
                            Stepper("Pañales Restantes: \(panalesRestantes)%", value: $panalesRestantes, in: 0...100, step: 5)
                                .accessibilityIdentifier("stepperPanalesRestantes")
                        }

                        // SECCIÓN: Detalles de la siesta.
                        Section(header: Text("Siesta")) {
                            Toggle("¿Realizó siesta?", isOn: $siesta)
                                .accessibilityIdentifier("toggleSiesta")
                            if siesta {
                                DatePicker("Inicio de la siesta", selection: $siestaInicio, displayedComponents: .hourAndMinute)
                                    .accessibilityIdentifier("siestaInicioPicker")
                                DatePicker("Fin de la siesta", selection: $siestaFin, displayedComponents: .hourAndMinute)
                                    .accessibilityIdentifier("siestaFinPicker")
                            }
                        }

                        // SECCIÓN: Comentarios adicionales.
                        Section(header: Text("Comentarios")) {
                            TextEditor(text: $comentarios)
                                .frame(height: 100)
                                .padding(4)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray, lineWidth: 1)
                                )
                                .accessibilityIdentifier("comentariosTextEditor")
                        }
                    }

                    // SECCIÓN: Mostrar registros existentes.
                    Section(header: Text("Registros Existentes")) {
                        ForEach(registros) { registro in
                            HStack {
                                VStack(alignment: .leading) {
                                    // Nombre del alumno asociado al registro.
                                    Text(registro.alumno?.nombre ?? "Sin Alumno")
                                        .font(.headline)
                                        .accessibilityIdentifier("nombreAlumnoRegistro_\(registro.id?.uuidString ?? "")")
                                    // Fecha del registro diario.
                                    Text("Fecha: \(registro.fecha ?? Date(), formatter: dateFormatter)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .accessibilityIdentifier("fechaRegistro_\(registro.id?.uuidString ?? "")")
                                }
                                Spacer()
                                // Botón para eliminar el registro.
                                Button(role: .destructive) {
                                    deleteRecord(registro) // Elimina el registro.
                                } label: {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                        .accessibilityIdentifier("eliminarRegistroButton_\(registro.id?.uuidString ?? "")")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Añadir/Eliminar Registro")
            .toolbar {
                // Botón para guardar un nuevo registro diario.
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        saveRecord() // Guarda el registro.
                    }
                    .disabled(selectedAlumno == nil) // Desactiva si no hay alumno seleccionado.
                    .accessibilityIdentifier("guardarRegistroButton")
                }
                // Botón para cancelar y cerrar la vista.
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss() // Cierra la vista.
                    }
                    .accessibilityIdentifier("cancelarRegistroButton")
                }
            }
        }
    }

    // Filtro de alumnos basado en la consulta de búsqueda.
    private func filterAlumnos() {
        filteredAlumnos = alumnos.filter { alumno in
            guard let nombre = alumno.nombre else { return false }
            return nombre.lowercased().contains(searchQuery.lowercased())
        }
    }

    // Guarda un registro diario en Core Data.
    private func saveRecord() {
        guard let alumno = selectedAlumno else { return }
        let newRecord = RegistroDiario(context: context)
        newRecord.id = UUID()
        newRecord.fecha = fecha
        newRecord.alumno = alumno
        newRecord.desayuno = desayuno
        newRecord.tentempie = tentempie
        newRecord.primerPlato = primerPlato
        newRecord.segundoPlato = segundoPlato
        newRecord.postre = postre
        newRecord.toallitasRestantes = Int16(toallitasRestantes)
        newRecord.panalesRestantes = Int16(panalesRestantes)
        newRecord.siesta = siesta
        newRecord.siestaInicio = siesta ? siestaInicio : nil
        newRecord.siestaFin = siesta ? siestaFin : nil
        newRecord.comentarios = comentarios
        do {
            try context.save()
            dismiss()
        } catch {
            print("Error al guardar el registro diario: \(error)")
        }
    }

    // Elimina un registro diario de Core Data.
    private func deleteRecord(_ registro: RegistroDiario) {
        context.delete(registro)
        do {
            try context.save()
        } catch {
            print("Error al eliminar el registro: \(error)")
        }
    }

    // Carga una imagen desde el sistema de archivos o los assets.
    private func loadImage(named fileName: String) -> UIImage? {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)
        if FileManager.default.fileExists(atPath: url.path) {
            return UIImage(contentsOfFile: url.path)
        }
        return UIImage(named: fileName)
    }

    // Formateador para mostrar fechas en formato local.
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.dateStyle = .medium
        return formatter
    }()
}
