//
//  TutorAlumnoView.swift
//  agendaescolaredai
//
//  Created by Juan Antonio Sánchez Carrillo on 18/11/24.
//

import SwiftUI
import CoreData

/// Vista mejorada que muestra información detallada de un alumno con un diseño amigable.
/// Presenta información básica del alumno y sus registros diarios en un diseño limpio y moderno.
struct TutorAlumnoView: View {
    /// Objeto `Alumno` cuya información será presentada.
    let student: Alumno

    /// Lista que contiene los registros diarios más recientes del alumno.
    @State private var registros: [RegistroDiario] = []

    /// Inicializador que asigna el alumno cuya información se va a mostrar.
    /// - Parameter student: Instancia del tipo `Alumno`.
    init(student: Alumno) {
        self.student = student
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                tarjetaDetallesAlumnoView // Tarjeta con detalles básicos del alumno.
                tarjetaRegistrosDiariosView // Tarjeta con registros diarios.
            }
            .padding(.horizontal)
            .frame(maxWidth: 600) // Ancho máximo uniforme para las tarjetas.
            .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all)) // Fondo gris claro.
        }
        .onAppear {
            fetchDailyRecords() // Carga los registros diarios al aparecer la vista.
        }
    }

    /// Tarjeta que contiene los detalles básicos del alumno.
    private var tarjetaDetallesAlumnoView: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(spacing: 20) {
                imagenAlumnoView // Imagen del alumno.

                VStack(alignment: .leading, spacing: 10) {
                    detalleCampo(titulo: "Nombre:", valor: student.nombre ?? "Sin Nombre")
                    detalleCampo(titulo: "Fecha de Nacimiento:", valor: student.fechaNacimiento ?? Date(), formatter: dateFormatter)
                    detalleCampo(titulo: "Aula:", valor: student.aula?.nombre ?? "Sin Aula")
                    detalleCampo(titulo: "Centro:", valor: student.centro?.nombre ?? "Sin Centro")
                    detalleCampo(titulo: "Curso:", valor: student.aula?.curso ?? "Sin Curso")
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.3), radius: 8, x: 0, y: 4)
        .frame(maxWidth: .infinity)
        .accessibilityIdentifier("tarjetaDetallesAlumno")
    }

    /// Tarjeta que contiene los registros diarios.
    private var tarjetaRegistrosDiariosView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Últimos Registros Diarios")
                .font(.headline)
                .padding(.bottom, 10)

            if registros.isEmpty {
                Text("Aún no hay registros diarios disponibles para este alumno.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                VStack(spacing: 15) {
                    ForEach(registros, id: \.id) { registro in
                        registroDiarioItem(registro: registro) // Vista individual de cada registro.
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.3), radius: 8, x: 0, y: 4)
        .frame(maxWidth: .infinity)
        .accessibilityIdentifier("tarjetaRegistrosDiarios")
    }

    /// Vista de cada registro diario en la lista con diseño vertical.
    private func registroDiarioItem(registro: RegistroDiario) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            // Fecha del registro diario y el ícono de comentarios si hay texto.
            HStack {
                Text("Fecha: \(registro.fecha ?? Date(), formatter: dateFormatter)")
                    .font(.subheadline)
                    .foregroundColor(.black)

                Spacer()

                if let comentarios = registro.comentarios, !comentarios.isEmpty {
                    Image("commentIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.blue)
                        .padding(.trailing, 5)
                }
            }

            // Íconos de comidas registradas.
            HStack(spacing: 10) {
                recordIcon("desayunoIcon", isActive: registro.desayuno)
                recordIcon("tentempieIcon", isActive: registro.tentempie)
                recordIcon("primerPlatoIcon", isActive: registro.primerPlato)
                recordIcon("segundoPlatoIcon", isActive: registro.segundoPlato)
                recordIcon("postreIcon", isActive: registro.postre)
                recordIcon("siestaIcon", isActive: registro.siesta)
            }

            // Inventario restante.
            HStack(spacing: 20) {
                inventoryIcon("toallitasIcon", title: "Toallitas", value: registro.toallitasRestantes)
                inventoryIcon("panalesIcon", title: "Pañales", value: registro.panalesRestantes)
            }

            // Mensaje de siesta, si aplica.
            if registro.siesta, let inicio = registro.siestaInicio, let fin = registro.siestaFin {
                Text("Ha dormido la siesta de \(timeFormatter.string(from: inicio)) a \(timeFormatter.string(from: fin))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Texto del comentario, si existe.
            if let comentarios = registro.comentarios, !comentarios.isEmpty {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Comentarios:")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    Text(comentarios)
                        .font(.body)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                }
                .padding(.top, 10)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
        .accessibilityIdentifier("registroDiarioItem")
    }

    /// Recupera los últimos tres registros diarios asociados al alumno desde Core Data.
    private func fetchDailyRecords() {
        if let registrosAlumno = student.registrosDiarios as? Set<RegistroDiario> {
            registros = Array(registrosAlumno)
                .sorted { $0.fecha ?? Date() > $1.fecha ?? Date() }
                .prefix(3)
                .map { $0 }
        }
    }

    /// Genera una vista para mostrar un campo de información con texto.
    private func detalleCampo(titulo: String, valor: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(titulo)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(valor)
                .font(.body)
                .bold()
        }
    }

    /// Genera una vista para mostrar un campo de información con fecha formateada.
    private func detalleCampo(titulo: String, valor: Date, formatter: DateFormatter) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(titulo)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(valor, formatter: formatter)
                .font(.body)
                .bold()
        }
    }

    /// Genera un ícono que representa si una comida fue registrada.
    private func recordIcon(_ imageName: String, isActive: Bool) -> some View {
        Image(imageName)
            .resizable()
            .scaledToFit()
            .frame(width: 50, height: 50)
            .opacity(isActive ? 1.0 : 0.3)
    }

    /// Genera una vista de inventario con alertas visuales si el nivel es bajo.
    private func inventoryIcon(_ imageName: String, title: String, value: Int16) -> some View {
        HStack(spacing: 6) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 35, height: 35)
            Text("\(title): \(value)%")
                .foregroundColor(.blue)
            if value < 25 {
                Image(systemName: "exclamationmark.triangle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 15, height: 15)
                    .foregroundColor(.red)
            }
        }
        .font(.body)
    }

    /// Genera la vista para mostrar la imagen del alumno.
    private var imagenAlumnoView: some View {
        Group {
            if let imageName = student.imagen, let uiImage = loadImage(named: imageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height: 200)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(hex: "#7BB2E0"), lineWidth: 3)
                    )
                    .shadow(radius: 5)
            } else {
                Image("placeHolder")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 150, height: 150)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(hex: "#7BB2E0"), lineWidth: 3)
                    )
                    .shadow(radius: 5)
            }
        }
    }

    /// Carga una imagen desde el sistema de archivos o los assets.
    private func loadImage(named fileName: String) -> UIImage? {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)
        if FileManager.default.fileExists(atPath: url.path) {
            return UIImage(contentsOfFile: url.path)
        }
        if let assetImage = UIImage(named: fileName) {
            return assetImage
        }
        return nil
    }

    /// Formateador de fecha para mostrar fechas en formato local.
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.dateStyle = .medium
        return formatter
    }()

    /// Formateador para mostrar horas en formato HH:mm.
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
}
