//
//  ProfesorAlumnosListView.swift
//  agendaescolaredai
//
//  Created by Juan Antonio Sánchez Carrillo on 16/11/24.
//

import SwiftUI

/// Vista que muestra los alumnos de las aulas asignadas al profesor.
struct ProfesorAlumnosListView: View {
    /// Usuario logueado como profesor.
    let profesor: Usuario

    /// FetchRequest para obtener alumnos de las aulas asignadas al profesor.
    @FetchRequest var alumnos: FetchedResults<Alumno>

    /// Estado para controlar el texto de búsqueda.
    @State private var searchText: String = ""

    /// Inicializador que configura el filtro de alumnos según las aulas del profesor.
    /// - Parameter profesor: Usuario con rol de profesor.
    init(profesor: Usuario) {
        // Crea un predicado para filtrar alumnos cuyas aulas tengan al profesor en la relación "profesores".
        let predicate = NSPredicate(format: "aula.profesores CONTAINS %@", profesor)
        // Configura el FetchRequest con el predicado y ordena los resultados por nombre en orden ascendente.
        _alumnos = FetchRequest(
            entity: Alumno.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Alumno.nombre, ascending: true)],
            predicate: predicate
        )
        self.profesor = profesor
    }

    var body: some View {
        // Vista principal dentro de un contenedor de navegación.
        NavigationView {
            VStack {
                // Encabezado de la vista.
                Text("Mis Alumnos")
                    .font(.title) // Fuente grande para el título.
                    .bold() // Aplica negrita.
                    .padding(.top) // Añade espacio en la parte superior.
                    .accessibilityIdentifier("misAlumnosTitle")

                // Barra de búsqueda para filtrar alumnos.
                SearchBar(text: $searchText, placeholder: "Buscar alumno")
                    .accessibilityIdentifier("searchBarAlumnos")

                // Lista que muestra a los alumnos filtrados.
                List(filteredAlumnos, id: \.id) { alumno in
                    // Navega a la vista de edición del alumno al seleccionarlo.
                    NavigationLink(destination: EditStudentView(student: alumno)) {
                        HStack {
                            // Imagen del alumno con borde personalizado.
                            if let imageName = alumno.imagen, !imageName.isEmpty, UIImage(named: imageName) != nil {
                                Image(imageName) // Carga la imagen asociada al alumno.
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100) // Tamaño de la imagen.
                                    .cornerRadius(12) // Esquinas redondeadas.
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color(hex: "#7BB2E0"), lineWidth: 3)
                                    ) // Borde decorativo.
                                    .shadow(radius: 5) // Sombra para la imagen.
                                    .accessibilityIdentifier("alumnoImage_\(alumno.id?.uuidString ?? "unknown")")
                            } else {
                                Image("placeHolder") // Imagen predeterminada si no hay una asignada.
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color(hex: "#7BB2E0"), lineWidth: 3)
                                    )
                                    .shadow(radius: 5)
                                    .accessibilityIdentifier("defaultAlumnoImage")
                            }

                            // Información del alumno.
                            VStack(alignment: .leading, spacing: 5) {
                                // Nombre del alumno.
                                Text(alumno.nombre ?? "Sin Nombre")
                                    .font(.headline)
                                    .accessibilityIdentifier("alumnoName_\(alumno.id?.uuidString ?? "unknown")")

                                // Edad del alumno calculada a partir de la fecha de nacimiento.
                                if let fechaNacimiento = alumno.fechaNacimiento {
                                    Text("Edad: \(calcularEdad(fecha: fechaNacimiento)) años")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .accessibilityIdentifier("alumnoEdad_\(alumno.id?.uuidString ?? "unknown")")
                                }

                                // Curso del aula asignada al alumno.
                                Text("Curso: \(alumno.aula?.curso ?? "Sin Curso")")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                                    .accessibilityIdentifier("alumnoCurso_\(alumno.id?.uuidString ?? "unknown")")
                            }

                            Spacer()
                        }
                        .padding(.vertical, 5)
                        .accessibilityIdentifier("alumnoRow_\(alumno.id?.uuidString ?? "unknown")")
                    }
                }
                .listStyle(PlainListStyle()) // Estilo de lista sin fondo gris predeterminado.
                .accessibilityIdentifier("alumnosList")
            }
            .background(Color.white) // Fondo blanco para todo el contenido.
            .navigationBarTitleDisplayMode(.inline) // Título alineado en línea con la barra de navegación.
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Estilo adaptado para dispositivos con pantallas pequeñas.
        .accessibilityIdentifier("profesorAlumnosView")
    }

    /// Calcula la edad del alumno a partir de la fecha de nacimiento.
    /// - Parameter fecha: Fecha de nacimiento del alumno.
    /// - Returns: Edad en años como entero.
    private func calcularEdad(fecha: Date) -> Int {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: fecha, to: Date())
        return ageComponents.year ?? 0
    }

    /// Devuelve los alumnos filtrados según el texto de búsqueda.
    private var filteredAlumnos: [Alumno] {
        if searchText.isEmpty {
            return alumnos.map { $0 }
        } else {
            return alumnos.filter {
                $0.nombre?.localizedCaseInsensitiveContains(searchText) ?? false
            }
        }
    }
}

/// Componente reutilizable para una barra de búsqueda.
struct SearchBar: View {
    @Binding var text: String // Texto de búsqueda.
    let placeholder: String // Texto de marcador de posición.

    var body: some View {
        HStack {
            TextField(placeholder, text: $text)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .accessibilityIdentifier("searchBarField")
        }
        .padding(.horizontal)
        .accessibilityIdentifier("searchBarContainer")
    }
}
