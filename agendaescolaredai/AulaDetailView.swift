//
//  AulaDetailView.swift
//  agendaescolaredai
//
//  Created by Juan Antonio Sánchez Carrillo on 16/11/24.
//

import SwiftUI
import CoreData

/// Vista de detalle para un aula específica.
/// Proporciona información completa sobre un aula seleccionada, como su imagen, curso, rango de edad, profesores asignados y alumnos.
/// También permite filtrar alumnos por nombre, editar la información del aula y acceder al perfil de los alumnos.
struct AulaDetailView: View {
    @Binding var aula: Aula // Aula seleccionada, vinculada para reflejar cambios en tiempo real.
    @Binding var searchText: String // Texto de búsqueda utilizado para filtrar alumnos, vinculado con la vista principal.

    @State private var selectedAlumno: Alumno? // Almacena el alumno seleccionado para ser editado.
    @State private var isEditing: Bool = false // Controla si se está editando la información del aula.

    var body: some View {
        VStack(spacing: 20) { // Contenedor principal con espacio vertical entre los elementos.
            
            // Sección inicial: información básica del aula.
            HStack(alignment: .top, spacing: 15) { // Disposición horizontal con alineación superior y espaciado fijo.
                
                // Imagen del aula, cargada desde el almacenamiento local o mostrada como marcador de posición.
                if let imageName = aula.imagen, !imageName.isEmpty, let uiImage = UIImage(named: imageName) {
                    Image(uiImage: uiImage) // Imagen válida cargada.
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120) // Dimensiones fijas.
                        .cornerRadius(12) // Esquinas redondeadas.
                        .overlay(
                            RoundedRectangle(cornerRadius: 12) // Borde decorativo.
                                .stroke(Color.gray, lineWidth: 2) // Color y grosor del borde.
                        )
                        .shadow(radius: 5) // Sombra alrededor de la imagen.
                        .accessibilityIdentifier("aulaDetailImage") // Identificador de accesibilidad.
                } else {
                    // Imagen predeterminada para aulas sin una imagen asociada.
                    Image("placeHolder")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray, lineWidth: 2)
                        )
                        .shadow(radius: 5)
                        .accessibilityIdentifier("aulaDetailPlaceholderImage") // Identificador de accesibilidad.
                }

                // Detalles textuales del aula.
                VStack(alignment: .leading, spacing: 10) { // Contenedor vertical con alineación a la izquierda y espaciado.
                    HStack {
                        Text(aula.nombre ?? "Sin nombre") // Nombre del aula.
                            .font(.largeTitle) // Estilo grande para destacar.
                            .fontWeight(.bold) // Texto en negrita.
                            .accessibilityIdentifier("aulaDetailName") // Identificador de accesibilidad.

                        Spacer()

                        // Botón para habilitar el modo de edición del aula.
                        Button(action: {
                            isEditing = true // Activa el modo de edición.
                        }) {
                            Image(systemName: "square.and.pencil") // Ícono de edición.
                                .font(.title2)
                                .foregroundColor(.blue) // Color azul para destacar.
                                .accessibilityIdentifier("aulaDetailEditButton") // Identificador de accesibilidad.
                        }
                        .sheet(isPresented: $isEditing) {
                            EditAulaView(aula: $aula) // Presenta la vista de edición del aula.
                        }
                    }

                    // Curso asignado al aula.
                    Text("Curso: \(aula.curso ?? "Sin curso")")
                        .font(.headline)
                        .foregroundColor(.blue) // Texto en color azul para destacar.
                        .accessibilityIdentifier("aulaDetailCourse")

                    // Rango de edades permitido en el aula.
                    Text("Rango de edad: \(aula.edadMinima)-\(aula.edadMaxima) años")
                        .font(.subheadline)
                        .foregroundColor(.gray) // Color gris para resaltar menos.
                        .accessibilityIdentifier("aulaDetailAgeRange")

                    // Número total de alumnos registrados en el aula.
                    Text("Total de alumnos: \(aula.alumnos?.count ?? 0)")
                        .font(.subheadline)
                        .accessibilityIdentifier("aulaDetailStudentCount")

                    // Lista de profesores asignados al aula.
                    if let profesores = aula.profesores?.allObjects as? [Usuario], !profesores.isEmpty {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Profesores Asignados:")
                                .font(.headline)
                                .padding(.top, 5) // Espaciado adicional en la parte superior.
                                .accessibilityIdentifier("aulaDetailTeachersHeader")

                            // Lista dinámica de profesores asignados.
                            ForEach(profesores, id: \.id) { profesor in
                                Text(profesor.nombre ?? "Sin nombre") // Nombre del profesor.
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                    .accessibilityIdentifier("aulaDetailTeacher_\(profesor.id?.uuidString ?? "unknown")") // Identificador único.
                            }
                        }
                    }
                }
                Spacer()
            }
            .padding()

            Divider() // Línea divisoria para separar secciones.
                .padding(.horizontal)

            // Barra de búsqueda para filtrar alumnos.
            TextField("Buscar alumno...", text: $searchText)
                .padding(10)
                .background(Color(.systemGray6)) // Fondo gris claro.
                .cornerRadius(8) // Bordes redondeados.
                .padding(.horizontal)
                .accessibilityIdentifier("aulaDetailSearchField") // Identificador de accesibilidad.

            // Sección que lista a los alumnos registrados en el aula.
            VStack(spacing: 10) {
                Text("Alumnos") // Título de la sección.
                    .font(.headline)
                    .accessibilityIdentifier("aulaDetailStudentsHeader") // Identificador de accesibilidad.

                // Lista de alumnos con sus detalles e imágenes.
                List(filteredAlumnos, id: \.id) { alumno in
                    Button(action: {
                        selectedAlumno = alumno // Selecciona el alumno para edición.
                    }) {
                        HStack(spacing: 15) {
                            // Imagen del alumno.
                            if let imageName = alumno.imagen, let uiImage = loadImage(named: imageName) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 60) // Dimensiones fijas.
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.gray, lineWidth: 1)
                                    )
                                    .accessibilityIdentifier("aulaDetailStudentImage_\(alumno.id?.uuidString ?? "unknown")") // Identificador único.
                            } else {
                                // Imagen de marcador de posición para alumnos sin imagen.
                                Image("placeHolder")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 60)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color(hex: "#7BB2E0"), lineWidth: 3)
                                    )
                                    .accessibilityIdentifier("aulaDetailStudentPlaceholderImage_\(alumno.id?.uuidString ?? "unknown")") // Identificador único.
                            }

                            // Nombre y edad del alumno.
                            VStack(alignment: .leading, spacing: 5) {
                                Text(alumno.nombre ?? "Sin nombre")
                                    .font(.headline)
                                    .accessibilityIdentifier("aulaDetailStudentName_\(alumno.id?.uuidString ?? "unknown")") // Identificador único.

                                if let fechaNacimiento = alumno.fechaNacimiento {
                                    Text("Edad: \(formatearEdad(fecha: fechaNacimiento))")
                                        .font(.subheadline)
                                        .foregroundColor(.gray) // Color gris para menos relevancia.
                                        .accessibilityIdentifier("aulaDetailStudentAge_\(alumno.id?.uuidString ?? "unknown")") // Identificador único.
                                }
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle()) // Estilo simple para la lista.
                .accessibilityIdentifier("aulaDetailStudentList") // Identificador de accesibilidad.
            }
            .frame(maxHeight: .infinity) // Expande para ocupar todo el espacio vertical disponible.
        }
        .padding() // Espaciado general.
        .background(Color(.systemBackground)) // Fondo adaptado al sistema.
        .navigationBarTitleDisplayMode(.inline) // Título alineado en línea con la barra de navegación.
        .sheet(item: $selectedAlumno) { alumno in
            EditStudentView(student: alumno) // Presenta la vista de edición del alumno seleccionado.
        }
    }

    /// Filtra y ordena los alumnos según el texto de búsqueda.
    private var filteredAlumnos: [Alumno] {
        guard let alumnos = aula.alumnos?.allObjects as? [Alumno] else { return [] } // Asegura que `alumnos` sea un arreglo.
        let sortedAlumnos = alumnos.sorted { ($0.nombre ?? "").localizedCaseInsensitiveCompare($1.nombre ?? "") == .orderedAscending } // Ordena alfabéticamente.
        if searchText.isEmpty {
            return sortedAlumnos // Devuelve todos si no hay búsqueda activa.
        } else {
            return sortedAlumnos.filter { alumno in
                alumno.nombre?.localizedCaseInsensitiveContains(searchText) == true // Filtra por coincidencias en el nombre.
            }
        }
    }

    /// Calcula y formatea la edad del alumno a partir de su fecha de nacimiento.
    private func formatearEdad(fecha: Date) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: fecha, to: Date()) // Calcula la diferencia en años y meses.
        if let years = components.year, years > 0 {
            return "\(years) años" // Devuelve años si es mayor a cero.
        } else if let months = components.month {
            return "\(months) meses" // Devuelve meses si no hay años.
        } else {
            return "Reciente" // Texto predeterminado para fechas muy cercanas.
        }
    }

    /// Carga una imagen desde el sistema de archivos o los recursos de la aplicación.
    private func loadImage(named fileName: String) -> UIImage? {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName) // Ruta completa del archivo.
        if FileManager.default.fileExists(atPath: url.path) {
            return UIImage(contentsOfFile: url.path) // Devuelve la imagen si existe en la ruta.
        }
        return UIImage(named: fileName) // Devuelve la imagen desde los recursos si no está en el sistema de archivos.
    }
}
