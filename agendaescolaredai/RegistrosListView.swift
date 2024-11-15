//
//  RegistrosListView.swift
//  agendaescolaredai
//
//  Created by Juan Antonio Sánchez Carrillo on 16/11/24.
//

import SwiftUI
import CoreData

/// Vista que muestra los registros diarios de los alumnos asociados a un profesor.
struct RegistrosListView: View {
    let teacher: Usuario

    @FetchRequest var registros: FetchedResults<RegistroDiario>
    @State private var searchText: String = ""

    init(teacher: Usuario) {
        let aulaPredicate = NSPredicate(format: "alumno.aula.profesores CONTAINS %@", teacher)
        _registros = FetchRequest(
            entity: RegistroDiario.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \RegistroDiario.fecha, ascending: false)],
            predicate: aulaPredicate
        )
        self.teacher = teacher
    }

    var body: some View {
        NavigationView {
            VStack {
                Text("Registros Diarios")
                    .font(.largeTitle)
                    .padding()
                    .accessibilityIdentifier("registrosDiariosTitle")

                TextField("Buscar por alumno...", text: $searchText)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .accessibilityIdentifier("searchAlumnoTextField")

                List {
                    ForEach(filteredRegistros, id: \.id) { registro in
                        registroRow(for: registro) // Función para mostrar cada registro.
                    }
                }
                .accessibilityIdentifier("registrosList")
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AddDailyRecordView()) {
                        Image(systemName: "plus")
                            .foregroundColor(.blue)
                            .accessibilityIdentifier("addRecordButton")
                    }
                }
            }
        }
    }

    /// Fila de vista para cada registro.
    private func registroRow(for registro: RegistroDiario) -> some View {
        NavigationLink(destination: EditDailyRecordView(registro: registro)) {
            VStack(alignment: .leading, spacing: 12) {
                registroHeader(for: registro) // Imagen, nombre, fecha y commentIcon.
                registroIcons(for: registro) // Íconos de comidas y siesta.
                registroInventory(for: registro) // Inventario de toallitas y pañales.
            }
            .padding(.vertical, 10)
        }
        .swipeActions {
            Button(role: .destructive) {
                deleteRegistro(registro)
            } label: {
                Label("Borrar", systemImage: "trash")
            }
        }
    }

    /// Encabezado del registro: Imagen, nombre, fecha y commentIcon.
    private func registroHeader(for registro: RegistroDiario) -> some View {
        HStack(spacing: 15) {
            if let imageName = registro.alumno?.imagen, let alumnoImage = UIImage(named: imageName) {
                Image(uiImage: alumnoImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(hex: "#7BB2E0"), lineWidth: 2)
                    )
                    .shadow(radius: 2)
            } else {
                Image("placeHolder")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(hex: "#7BB2E0"), lineWidth: 2)
                    )
                    .shadow(radius: 2)
            }

            VStack(alignment: .leading) {
                HStack {
                    if let comentario = registro.comentarios, !comentario.isEmpty {
                        Image("commentIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.blue)
                            .padding(.trailing, 5)
                    }

                    Text(registro.alumno?.nombre ?? "Sin Alumno")
                        .font(.headline)
                        .foregroundColor(Color(hex: "#7BB2E0"))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Text("Fecha: \(registro.fecha ?? Date(), formatter: dateFormatter)")
                    .font(.subheadline)
                    .foregroundColor(.black)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    /// Íconos de comidas y siesta.
    private func registroIcons(for registro: RegistroDiario) -> some View {
        HStack(spacing: 10) {
            recordIcon("desayunoIcon", isActive: registro.desayuno)
            recordIcon("tentempieIcon", isActive: registro.tentempie)
            recordIcon("primerPlatoIcon", isActive: registro.primerPlato)
            recordIcon("segundoPlatoIcon", isActive: registro.segundoPlato)
            recordIcon("postreIcon", isActive: registro.postre)
            recordIcon("siestaIcon", isActive: registro.siesta)
        }
    }

    /// Inventario de pañales y toallitas.
    private func registroInventory(for registro: RegistroDiario) -> some View {
        HStack(spacing: 20) {
            inventoryRow("toallitasIcon", title: "Toallitas", percentage: registro.toallitasRestantes)
            inventoryRow("panalesIcon", title: "Pañales", percentage: registro.panalesRestantes)
        }
    }

    /// Filtra los registros basándose en el texto ingresado en la barra de búsqueda.
    private var filteredRegistros: [RegistroDiario] {
        registros.filter { registro in
            searchText.isEmpty || registro.alumno?.nombre?.localizedCaseInsensitiveContains(searchText) == true
        }
    }

    /// Elimina un registro de Core Data.
    private func deleteRegistro(_ registro: RegistroDiario) {
        let context = PersistenceController.shared.context
        context.delete(registro)

        do {
            try context.save()
        } catch {
            print("Error al eliminar el registro: \(error.localizedDescription)")
        }
    }

    private func recordIcon(_ imageName: String, isActive: Bool) -> some View {
        Image(imageName)
            .resizable()
            .scaledToFit()
            .frame(width: 40, height: 40)
            .opacity(isActive ? 1.0 : 0.3)
            .accessibilityIdentifier("\(imageName)_\(isActive ? "active" : "inactive")")
    }

    private func inventoryRow(_ imageName: String, title: String, percentage: Int16) -> some View {
        HStack(spacing: 5) {
            fillableIcon(imageName, percentage: percentage)
            Text("\(title): \(percentage)%")
                .font(.footnote)
                .foregroundColor(percentage < 20 ? .red : .gray)

            if percentage < 20 {
                Image(systemName: "exclamationmark.triangle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 15, height: 15)
                    .foregroundColor(.red)
            }
        }
    }

    private func fillableIcon(_ imageName: String, percentage: Int16) -> some View {
        ZStack {
            // Fondo del ícono con opacidad reducida (vacío).
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .opacity(0.3)

            // Ícono relleno desde abajo hacia arriba.
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .mask(
                    VStack(spacing: 0) {
                        Spacer() // El espacio vacío queda en la parte superior.
                        Rectangle()
                            .frame(height: CGFloat(40) * CGFloat(percentage) / 100.0) // Altura proporcional al porcentaje.
                    }
                )
                .opacity(1.0) // Asegura que el ícono relleno sea completamente visible.
        }
        .accessibilityIdentifier("\(imageName)_percentage_\(percentage)")
    }


    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.dateStyle = .medium
        return formatter
    }()
}
