//
//  EditStudentView.swift
//  agendaescolaredai
//
//  Created by Juan Antonio Sánchez Carrillo on 16/11/24.
//

import SwiftUI
import PhotosUI
import CoreData

/// Vista para editar la información de un alumno.
struct EditStudentView: View {
    // Contexto de Core Data proporcionado por el entorno.
    @Environment(\.managedObjectContext) private var context
    // Controla el cierre de la vista.
    @Environment(\.dismiss) private var dismiss

    // Estados locales para almacenar la información editable del alumno.
    @State private var name: String // Nombre del alumno.
    @State private var birthDate: Date // Fecha de nacimiento del alumno.
    @State private var course: String // Curso actual del aula asociada al alumno.
    @State private var tutor: String // Tutor Asociado al Alumno
    @State private var selectedItem: PhotosPickerItem? // Imagen seleccionada desde la galería.
    @State private var selectedImage: UIImage? // Previsualización de la imagen seleccionada.
    @State private var registros: [RegistroDiario] = [] // Últimos registros diarios del alumno.

    // Alumno que se está editando.
    let student: Alumno

    /// Inicializador que configura los valores iniciales a partir del alumno proporcionado.
    /// - Parameter student: Alumno a editar.
    init(student: Alumno) {
        self.student = student
        _name = State(initialValue: student.nombre ?? "")
        _birthDate = State(initialValue: student.fechaNacimiento ?? Date())
        _course = State(initialValue: student.aula?.curso ?? "Sin Curso")
        _tutor = State(initialValue: student.tutor?.nombre ?? "Sin Tutor Asignado")
    }

    var body: some View {
        // Vista principal en un contenedor con scroll.
        ScrollView {
            VStack(spacing: 20) {
                // Encabezado de la vista.
                Text("Editar Alumno")
                    .font(.largeTitle) // Título principal en formato grande.
                    .bold() // Negrita para resaltar.
                    .padding() // Espaciado alrededor del título.
                    .accessibilityIdentifier("editStudentTitle") // Identificador de accesibilidad.

                // Contenedor horizontal para la imagen y los datos.
                HStack(alignment: .top, spacing: 20) {
                    VStack {
                        // Imagen del alumno.
                        if let selectedImage = selectedImage {
                            // Si el usuario seleccionó una imagen nueva.
                            Image(uiImage: selectedImage)
                                .resizable() // Permite redimensionar la imagen.
                                .scaledToFill() // Escala la imagen para llenar su contenedor.
                                .frame(width: 150, height: 150) // Define el tamaño de la imagen.
                                .cornerRadius(12) // Bordes redondeados.
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(hex: "#7BB2E0"), lineWidth: 3) // Borde azul personalizado.
                                )
                                .shadow(radius: 5) // Sombra para resaltar la imagen.
                        } else if let imageName = student.imagen, let uiImage = loadImage(named: imageName) {
                            // Si existe una imagen previamente guardada asociada al alumno.
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 150, height: 150)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(hex: "#7BB2E0"), lineWidth: 3)
                                )
                                .shadow(radius: 5)
                        } else {
                            // Imagen predeterminada si no hay ninguna asociada.
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

                        // Botón para seleccionar una nueva imagen.
                        PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                            Text("Editar Imagen")
                                .font(.subheadline) // Fuente secundaria para el texto del botón.
                                .padding(8) // Espaciado interno.
                                .background(Color.blue) // Fondo azul para el botón.
                                .foregroundColor(.white) // Texto blanco para contraste.
                                .cornerRadius(8) // Bordes redondeados.
                        }
                        .onChange(of: selectedItem) { oldValue, newValue in
                            // Detecta cambios en la selección de la imagen.
                            if oldValue != newValue {
                                handleImageSelection() // Llama a la función para manejar la selección.
                            }
                        }
                        .accessibilityIdentifier("editStudentImagePicker") // Identificador de accesibilidad.
                    }

                    // Contenedor para los datos del alumno.
                    VStack(alignment: .leading, spacing: 15) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Nombre:")
                                .font(.headline) // Estilo de encabezado.
                            TextField("Introduce el nombre", text: $name)
                                .textFieldStyle(RoundedBorderTextFieldStyle()) // Campo de texto redondeado.
                                .accessibilityIdentifier("editStudentNameField") // Identificador de accesibilidad.
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Fecha de Nacimiento:")
                                .font(.headline)
                            DatePicker("Selecciona una fecha", selection: $birthDate, displayedComponents: .date)
                                .environment(\.locale, Locale(identifier: "es_ES")) // Configura el idioma del calendario.
                                .labelsHidden() // Oculta la etiqueta del `DatePicker`.
                                .accessibilityIdentifier("editStudentBirthDatePicker")
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Curso:")
                                .font(.headline)
                            TextField("Introduce el curso", text: $course)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .accessibilityIdentifier("editStudentCourseField")
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tutor:")
                                .font(.headline)
                            TextField("Tutor Asignado", text: $tutor)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .accessibilityIdentifier("editStudentTutorField")
                        }
                    }
                }
                .padding(.horizontal) // Espaciado horizontal para separar contenido de los bordes.

                Divider() // Línea divisoria para separar secciones.

                // Título para los registros diarios recientes.
                Text("Últimos Registros Diarios")
                    .font(.headline)
                    .padding(.top)
                    .accessibilityIdentifier("editStudentDailyRecordsTitle")

                // Lista de registros diarios recientes.
                LazyVStack(spacing: 10) {
                    ForEach(registros, id: \.id) { registro in
                        HStack(spacing: 10) {
                            VStack(alignment: .leading, spacing: 8) {
                                // Fecha del registro diario.
                                Text("Fecha: \(registro.fecha ?? Date(), formatter: dateFormatter)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)

                                // Íconos de comidas realizadas.
                                HStack {
                                    recordIcon("desayunoIcon", isActive: registro.desayuno)
                                    recordIcon("tentempieIcon", isActive: registro.tentempie)
                                    recordIcon("primerPlatoIcon", isActive: registro.primerPlato)
                                    recordIcon("segundoPlatoIcon", isActive: registro.segundoPlato)
                                    recordIcon("postreIcon", isActive: registro.postre)
                                }

                                // Íconos de inventario.
                                HStack {
                                    inventoryIcon("toallitasIcon", title: "Toallitas", value: registro.toallitasRestantes)
                                    inventoryIcon("panalesIcon", title: "Pañales", value: registro.panalesRestantes)
                                }
                            }
                        }
                        .padding(.vertical, 5)
                        .padding(.horizontal, 10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 2)
                        .accessibilityIdentifier("editStudentDailyRecord_\(registro.fecha ?? Date())")
                    }
                }
                .padding(.horizontal)

                Spacer()

                // Botones para cancelar o guardar los cambios.
                HStack(spacing: 20) {
                    Button("Cancelar") {
                        dismiss() // Cierra la vista sin guardar cambios.
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.gray)
                    .cornerRadius(8)
                    .accessibilityIdentifier("editStudentCancelButton")

                    Button("Guardar") {
                        saveChanges() // Guarda los cambios realizados.
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(8)
                    .accessibilityIdentifier("editStudentSaveButton")
                }
                .padding(.bottom) // Espaciado inferior.
            }
            .padding()
        }
        .onAppear {
            fetchDailyRecords() // Recupera los registros diarios al cargar la vista.
        }
    }

    /// Maneja la selección de una imagen desde la galería.
    private func handleImageSelection() {
        guard let selectedItem else { return }
        Task {
            if let data = try? await selectedItem.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                selectedImage = uiImage // Actualiza la imagen seleccionada.
            }
        }
    }

    /// Recupera los últimos 3 registros diarios del alumno desde Core Data.
    private func fetchDailyRecords() {
        if let registrosAlumno = student.registrosDiarios as? Set<RegistroDiario> {
            registros = Array(registrosAlumno)
                .sorted { $0.fecha ?? Date() > $1.fecha ?? Date() }
                .prefix(3) // Limita a los 3 registros más recientes.
                .map { $0 }
        }
    }

    /// Guarda los cambios realizados en la información del alumno.
    private func saveChanges() {
        student.nombre = name
        student.fechaNacimiento = birthDate
        student.aula?.curso = course

        // Si hay una nueva imagen seleccionada, guárdala en el disco.
        if let selectedImage = selectedImage {
            student.imagen = saveImageToDisk(image: selectedImage)
        }

        // Guarda los cambios en Core Data.
        do {
            try context.save()
            dismiss()
        } catch {
            print("Error al guardar los cambios: \(error.localizedDescription)")
        }
    }

    /// Guarda una imagen en el sistema de archivos local y devuelve el nombre del archivo.
    private func saveImageToDisk(image: UIImage) -> String {
        let fileName = UUID().uuidString + ".png"
        if let imageData = image.pngData() {
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent(fileName)
            do {
                try imageData.write(to: url)
                return fileName
            } catch {
                print("Error al guardar la imagen: \(error.localizedDescription)")
            }
        }
        return "placeHolder"
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

    /// Crea un ícono visual para cada comida registrada.
    private func recordIcon(_ imageName: String, isActive: Bool) -> some View {
        Image(imageName)
            .resizable()
            .scaledToFit()
            .frame(width: 24, height: 24)
            .opacity(isActive ? 1.0 : 0.3)
    }

    /// Crea una vista de inventario con íconos y alerta si es menor de 25.
    private func inventoryIcon(_ imageName: String, title: String, value: Int16) -> some View {
        HStack(spacing: 4) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
            Text("\(title): \(value)%")
                .foregroundColor(.blue)

            if value < 25 {
                Image(systemName: "exclamationmark.triangle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .foregroundColor(.red)
            }
        }
        .font(.footnote)
    }
}
