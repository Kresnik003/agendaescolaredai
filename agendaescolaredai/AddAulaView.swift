//
//  AddAulaView.swift
//  agendaescolaredai
//
//  Created by Juan Antonio Sánchez Carrillo on 22/11/24.
//

import SwiftUI
import CoreData

/// Vista que permite crear un aula nueva, definiendo nombre, curso, rango de edades,
/// profesores asignados y una imagen representativa.
struct AddAulaView: View {
    @Environment(\.managedObjectContext) private var context // Contexto de Core Data para persistir los datos.
    @Environment(\.dismiss) private var dismiss // Control para cerrar la vista.

    // Estados que almacenan los datos ingresados por el usuario.
    @State private var nombre: String = "" // Nombre del aula.
    @State private var curso: String = "" // Curso del aula.
    @State private var edadMinima: Int = 0 // Edad mínima de los alumnos permitidos en el aula.
    @State private var edadMaxima: Int = 4 // Edad máxima de los alumnos permitidos en el aula.
    @State private var selectedImage: UIImage? // Imagen representativa seleccionada por el usuario.
    @State private var profesoresSeleccionados: [Usuario] = [] // Lista de profesores asignados al aula.

    /// Recupera los profesores disponibles desde Core Data. Filtra solo los usuarios con rol `profesor`.
    @FetchRequest(
        entity: Usuario.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Usuario.nombre, ascending: true)],
        predicate: NSPredicate(format: "rol == %@", "profesor")
    ) private var profesores: FetchedResults<Usuario>

    var body: some View {
        NavigationView {
            Form {
                // SECCIÓN: Información del aula.
                Section(header: Text("Información del Aula")) {
                    // Campo de texto para el nombre del aula.
                    TextField("Nombre", text: $nombre)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .accessibilityIdentifier("nombreTextField")

                    // Campo de texto para el curso del aula.
                    TextField("Curso", text: $curso)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .accessibilityIdentifier("cursoTextField")
                }

                // SECCIÓN: Rango de edades permitidas en el aula.
                Section(header: Text("Rango de Edades")) {
                    // Control para ajustar la edad mínima.
                    Stepper("Edad Mínima: \(edadMinima)", value: $edadMinima, in: 0...edadMaxima)
                        .accessibilityIdentifier("edadMinimaStepper")

                    // Control para ajustar la edad máxima.
                    Stepper("Edad Máxima: \(edadMaxima)", value: $edadMaxima, in: edadMinima...18)
                        .accessibilityIdentifier("edadMaximaStepper")
                }

                // SECCIÓN: Imagen del aula.
                Section(header: Text("Imagen del Aula")) {
                    if let selectedImage = selectedImage {
                        // Muestra la imagen seleccionada con estilo.
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray, lineWidth: 2)
                            )
                            .shadow(radius: 5)
                            .accessibilityIdentifier("selectedImageView")
                    } else {
                        // Mensaje predeterminado si no se selecciona ninguna imagen.
                        Text("No se ha seleccionado una imagen")
                            .foregroundColor(.gray)
                            .accessibilityIdentifier("noImageText")
                    }

                    // Botón para abrir el selector de imágenes.
                    Button("Seleccionar Imagen") {
                        selectImage()
                    }
                    .accessibilityIdentifier("selectImageButton")
                }

                // SECCIÓN: Profesores asignados al aula.
                Section(header: Text("Profesores Asignados")) {
                    // Lista de profesores con opciones de selección múltiple.
                    List(profesores, id: \.id) { profesor in
                        MultipleSelectionRow(
                            title: profesor.nombre ?? "Sin Nombre",
                            isSelected: profesoresSeleccionados.contains(profesor)
                        ) {
                            // Alterna entre seleccionar y deseleccionar al profesor.
                            if let index = profesoresSeleccionados.firstIndex(of: profesor) {
                                profesoresSeleccionados.remove(at: index)
                            } else {
                                profesoresSeleccionados.append(profesor)
                            }
                        }
                        .accessibilityIdentifier("profesorRow-\(profesor.id?.uuidString ?? "unknown")")
                    }
                }
            }
            .navigationTitle("Agregar Aula") // Título de la vista.
            .toolbar {
                // Botón para guardar el aula.
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        saveAula() // Llama a la función que guarda el aula.
                    }
                    .accessibilityIdentifier("guardarButton")
                }
                // Botón para cancelar la creación del aula.
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss() // Cierra la vista sin guardar.
                    }
                    .accessibilityIdentifier("cancelarButton")
                }
            }
        }
    }

    /// Abre un selector de imágenes. Personalizable según las necesidades (ejemplo: PhotosPicker).
    private func selectImage() {
        print("Abrir selector de imágenes")
    }

    /// Guarda el aula en la base de datos de Core Data.
    private func saveAula() {
        // Verifica que los campos obligatorios no estén vacíos.
        guard !nombre.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !curso.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("El nombre y curso son obligatorios.")
            return
        }

        // Crea un objeto `Aula` y asigna sus propiedades.
        let nuevaAula = Aula(context: context)
        nuevaAula.id = UUID()
        nuevaAula.nombre = nombre.trimmingCharacters(in: .whitespacesAndNewlines)
        nuevaAula.curso = curso.trimmingCharacters(in: .whitespacesAndNewlines)
        nuevaAula.edadMinima = Int16(edadMinima)
        nuevaAula.edadMaxima = Int16(edadMaxima)
        nuevaAula.profesores = NSSet(array: profesoresSeleccionados)

        // Guarda la imagen seleccionada si está disponible.
        if let selectedImage = selectedImage {
            nuevaAula.imagen = saveImageToDisk(image: selectedImage)
        }

        do {
            try context.save() // Guarda los cambios en Core Data.
            print("Aula creada correctamente.")
            dismiss() // Cierra la vista tras guardar exitosamente.
        } catch {
            print("Error al guardar el aula: \(error.localizedDescription)")
        }
    }

    /// Guarda la imagen en el sistema de archivos y devuelve el nombre del archivo.
    private func saveImageToDisk(image: UIImage) -> String {
        let fileName = UUID().uuidString + ".png"
        if let imageData = image.pngData() {
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent(fileName)
            do {
                try imageData.write(to: url)
                print("Imagen guardada en: \(url.path)")
                return fileName
            } catch {
                print("Error al guardar la imagen: \(error.localizedDescription)")
            }
        }
        return "placeHolder"
    }
}

/// Componente para gestionar la selección múltiple de elementos.
/// Usado para asignar profesores a un aula.
struct MultipleSelectionRow: View {
    let title: String // Título que representa el elemento.
    let isSelected: Bool // Estado actual del elemento (seleccionado o no).
    let action: () -> Void // Acción a ejecutar al interactuar con el elemento.

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .accessibilityIdentifier("profesorName-\(title)")
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                        .accessibilityIdentifier("checkmarkIcon-\(title)")
                }
            }
        }
        .accessibilityIdentifier("multipleSelectionRow-\(title)")
    }
}
