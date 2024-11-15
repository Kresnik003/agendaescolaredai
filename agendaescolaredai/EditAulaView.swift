//
//  EditAulaView.swift
//  agendaescolaredai
//
//  Created by Juan Antonio Sánchez Carrillo on 20/11/24.
//

import SwiftUI
import CoreData

/// Vista para editar la información de un aula específica.
/// Esta vista permite al usuario modificar atributos como nombre, curso, rango de edad, imagen y asignación de profesores.
struct EditAulaView: View {
    // MARK: - Entornos

    @Environment(\.managedObjectContext) private var context // Contexto de Core Data para gestionar la persistencia de datos.
    @Environment(\.dismiss) private var dismiss // Permite cerrar esta vista en la pila de navegación.

    // MARK: - Variables principales

    /// Binding al aula que se está editando. Los cambios realizados en esta vista se reflejan directamente en el objeto principal.
    @Binding var aula: Aula

    // MARK: - Estados internos

    /// Almacena los valores iniciales de los campos para que puedan ser editados en tiempo real.
    @State private var nombre: String // Nombre del aula.
    @State private var curso: String // Curso asociado al aula.
    @State private var edadMinima: Int16 // Edad mínima de los alumnos permitidos.
    @State private var edadMaxima: Int16 // Edad máxima de los alumnos permitidos.
    @State private var profesores: [Usuario] // Lista de profesores asignados al aula.
    @State private var todosLosProfesores: [Usuario] = [] // Lista de todos los profesores disponibles para asignación.
    @State private var nombreImagen: String // Nombre del archivo de imagen del aula.

    // MARK: - Inicialización

    /// Inicializa la vista con valores iniciales basados en el aula proporcionada.
    /// - Parameter aula: Aula que se desea editar, pasada como enlace (`Binding`) para que los cambios se reflejen.
    init(aula: Binding<Aula>) {
        self._aula = aula
        _nombre = State(initialValue: aula.wrappedValue.nombre ?? "") // Si no hay nombre definido, se usa una cadena vacía.
        _curso = State(initialValue: aula.wrappedValue.curso ?? "") // Si no hay curso definido, se usa una cadena vacía.
        _edadMinima = State(initialValue: aula.wrappedValue.edadMinima) // Se asigna la edad mínima actual del aula.
        _edadMaxima = State(initialValue: aula.wrappedValue.edadMaxima) // Se asigna la edad máxima actual del aula.
        _profesores = State(initialValue: (aula.wrappedValue.profesores?.allObjects as? [Usuario]) ?? []) // Convierte el conjunto de profesores en un arreglo.
        _nombreImagen = State(initialValue: aula.wrappedValue.imagen ?? "") // Si no hay imagen definida, se usa una cadena vacía.
    }

    // MARK: - Vista principal

    var body: some View {
        NavigationView { // Crea un contenedor de navegación.
            Form { // Organiza los elementos en un formulario con secciones.
                // SECCIÓN 1: IMAGEN DEL AULA
                Section(header: Text("Imagen del Aula")) {
                    VStack {
                        // Muestra una vista previa de la imagen o un marcador de posición si no existe.
                        if let uiImage = UIImage(named: nombreImagen), !nombreImagen.isEmpty {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit() // Escala la imagen para que se ajuste proporcionalmente.
                                .frame(height: 150) // Define un tamaño fijo para la imagen.
                                .cornerRadius(10) // Aplica bordes redondeados.
                                .accessibilityIdentifier("editAulaImagePreview") // Identificador de accesibilidad.
                        } else {
                            Image("placeHolder") // Imagen de marcador de posición.
                                .resizable()
                                .scaledToFit()
                                .frame(height: 150)
                                .cornerRadius(10)
                                .accessibilityIdentifier("editAulaPlaceholderImage")
                        }
                        // Campo de texto para modificar el nombre del archivo de imagen.
                        TextField("Nombre de la imagen", text: $nombreImagen)
                            .textFieldStyle(RoundedBorderTextFieldStyle()) // Estilo visual redondeado.
                            .accessibilityIdentifier("editAulaImageTextField")
                    }
                }

                // SECCIÓN 2: INFORMACIÓN GENERAL DEL AULA
                Section(header: Text("Información del Aula")) {
                    // Campo para editar el nombre del aula.
                    TextField("Nombre", text: $nombre)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .accessibilityIdentifier("editAulaNameField")

                    // Campo para editar el curso asociado al aula.
                    TextField("Curso", text: $curso)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .accessibilityIdentifier("editAulaCourseField")

                    // Campos combinados para definir el rango de edad.
                    HStack {
                        Text("Rango de edad:")
                            .accessibilityIdentifier("editAulaAgeRangeLabel")
                        Spacer() // Deja espacio entre el texto y los campos de entrada.
                        // Campo para la edad mínima.
                        TextField("Mínima", value: $edadMinima, formatter: edadFormatter)
                            .keyboardType(.numberPad) // Estilo de teclado numérico.
                            .frame(width: 50)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .accessibilityIdentifier("editAulaAgeMinField")
                        Text("-") // Separador visual.
                        // Campo para la edad máxima.
                        TextField("Máxima", value: $edadMaxima, formatter: edadFormatter)
                            .keyboardType(.numberPad)
                            .frame(width: 50)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .accessibilityIdentifier("editAulaAgeMaxField")
                    }
                }

                // SECCIÓN 3: PROFESORES ASIGNADOS
                Section(header: Text("Profesores Asignados")) {
                    // Lista de profesores con opción de asignar o desasignar.
                    ForEach(todosLosProfesores, id: \.id) { profesor in
                        HStack {
                            Text(profesor.nombre ?? "Sin nombre")
                                .accessibilityIdentifier("editAulaProfesorName_\(profesor.id?.uuidString ?? "unknown")")
                            Spacer() // Alinea los íconos a la derecha.
                            // Si el profesor ya está asignado, muestra un ícono marcado.
                            if profesores.contains(where: { $0.id == profesor.id }) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green) // Color verde indica asignado.
                                    .onTapGesture {
                                        removeProfesor(profesor) // Desasigna al profesor al tocar el ícono.
                                    }
                                    .accessibilityIdentifier("editAulaProfesorAssigned_\(profesor.id?.uuidString ?? "unknown")")
                            } else {
                                // Si el profesor no está asignado, muestra un ícono vacío.
                                Image(systemName: "circle")
                                    .foregroundColor(.gray) // Color gris indica no asignado.
                                    .onTapGesture {
                                        addProfesor(profesor) // Asigna al profesor al tocar el ícono.
                                    }
                                    .accessibilityIdentifier("editAulaProfesorUnassigned_\(profesor.id?.uuidString ?? "unknown")")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Editar Aula") // Título de la barra de navegación.
            .toolbar {
                // Botón para regresar.
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Atrás") {
                        dismiss() // Cierra la vista sin guardar.
                    }
                    .accessibilityIdentifier("editAulaBackButton")
                }
                // Botón para guardar cambios.
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        saveChanges() // Guarda los cambios realizados.
                        dismiss() // Cierra la vista.
                    }
                    .accessibilityIdentifier("editAulaSaveButton")
                }
            }
            .onAppear {
                fetchProfesores() // Recupera los profesores disponibles al cargar la vista.
            }
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Configuración para una navegación apilada.
        .accessibilityIdentifier("editAulaView")
    }

    // MARK: - Funciones auxiliares

    /// Recupera todos los profesores disponibles desde Core Data.
    private func fetchProfesores() {
        let fetchRequest: NSFetchRequest<Usuario> = Usuario.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "rol == %@", "profesor") // Filtra los usuarios con rol "profesor".
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "nombre", ascending: true)] // Ordena alfabéticamente.

        do {
            todosLosProfesores = try context.fetch(fetchRequest) // Realiza la consulta.
        } catch {
            print("Error al recuperar los profesores: \(error.localizedDescription)") // Mensaje de error.
        }
    }

    /// Añade un profesor a la lista de asignados.
    private func addProfesor(_ profesor: Usuario) {
        if !profesores.contains(where: { $0.id == profesor.id }) {
            profesores.append(profesor)
        }
    }

    /// Elimina un profesor de la lista de asignados.
    private func removeProfesor(_ profesor: Usuario) {
        profesores.removeAll(where: { $0.id == profesor.id })
    }

    /// Guarda los cambios realizados en el aula.
    private func saveChanges() {
        aula.nombre = nombre
        aula.curso = curso
        aula.edadMinima = edadMinima
        aula.edadMaxima = edadMaxima
        aula.profesores = NSSet(array: profesores) // Actualiza la lista de profesores asignados.
        aula.imagen = nombreImagen

        do {
            try context.save() // Intenta guardar los cambios.
        } catch {
            print("Error al guardar los cambios: \(error.localizedDescription)") // Manejo de errores.
        }
    }

    /// Formateador para limitar el rango de edades en los campos numéricos.
    private let edadFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.minimum = 0 // Edad mínima permitida.
        formatter.maximum = 150 // Edad máxima permitida.
        return formatter
    }()
}
