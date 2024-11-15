//
//  AdminUsersListView.swift
//  agendaescolaredai
//
//  Created by Juan Antonio Sánchez Carrillo on 22/11/24.
//

import SwiftUI
import CoreData

/// Vista que permite al administrador gestionar usuarios y alumnos.
struct AdminUsersListView: View {
    @Environment(\.managedObjectContext) private var context // Contexto de Core Data para gestionar persistencia.
    @State private var isExpanded: Bool = false // Control del estado expandido.

    /// FetchRequest para obtener usuarios y alumnos desde Core Data.
    @FetchRequest(
        entity: Usuario.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Usuario.nombre, ascending: true)]
    ) var usuarios: FetchedResults<Usuario> // Recupera los usuarios ordenados alfabéticamente.

    @FetchRequest(
        entity: Alumno.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Alumno.nombre, ascending: true)]
    ) var alumnos: FetchedResults<Alumno> // Recupera los alumnos ordenados alfabéticamente.

    // Estados locales para búsqueda, selección y control de vistas.
    @State private var searchText: String = "" // Texto de búsqueda.
    @State private var showAddUser = false // Control para mostrar la vista de añadir usuario.
    @State private var showAddStudent = false // Control para mostrar la vista de añadir alumno.
    @State private var selectedUser: Usuario? // Usuario seleccionado para editar.
    @State private var selectedStudent: Alumno? // Alumno seleccionado para editar.
    @State private var showToast = false // Control para mostrar mensajes Toast.
    @State private var toastMessage = "" // Mensaje del Toast.
    @State private var isError = false // Indica si el mensaje Toast es de error.

    var body: some View {
        NavigationView {
            VStack {
                // Barra de búsqueda.
                TextField("Buscar usuario o alumno...", text: $searchText)
                    .padding() // Añade espaciado interno.
                    .background(Color(.systemGray6)) // Fondo gris claro.
                    .cornerRadius(8) // Bordes redondeados.
                    .padding(.horizontal) // Espaciado lateral.
                    .accessibilityIdentifier("searchField") // Identificador para pruebas.

                // Lista de usuarios y alumnos.
                List {
                    // Sección de usuarios.
                    UsersSection(
                        filteredUsers: filteredUsers,
                        onUserSelected: { user in
                            selectedUser = user // Asigna el usuario seleccionado.
                        },
                        onDelete: deleteUser // Acción para eliminar un usuario.
                    )

                    // Sección de alumnos.
                    StudentsSection(
                        filteredStudents: filteredStudents,
                        onStudentSelected: { student in
                            selectedStudent = student // Asigna el alumno seleccionado.
                        },
                        onDelete: deleteStudent // Acción para eliminar un alumno.
                    )
                }
                .listStyle(PlainListStyle()) // Estilo de lista simple.
                .accessibilityIdentifier("usersAndStudentsList") // Identificador de accesibilidad.

                Spacer() // Añade un espaciado flexible.

                // Botones para agregar usuarios y alumnos.
                HStack {
                    Button(action: { showAddUser.toggle() }) {
                        Label("Añadir Usuario", systemImage: "person.fill.badge.plus")
                            .frame(maxWidth: .infinity) // Ocupa todo el ancho disponible.
                            .padding() // Espaciado interno.
                            .background(Color(hex: "#7BB2E0")) // Fondo azul.
                            .foregroundColor(.white) // Texto blanco.
                            .cornerRadius(10) // Bordes redondeados.
                    }
                    .sheet(isPresented: $showAddUser) {
                        AddUserView()
                            .environment(\.managedObjectContext, context)
                    }
                    .accessibilityIdentifier("addUserButton") // Identificador para pruebas.

                    Button(action: { showAddStudent.toggle() }) {
                        Label("Añadir Alumno", systemImage: "person.fill.badge.plus")
                            .frame(maxWidth: .infinity) // Ocupa todo el ancho disponible.
                            .padding() // Espaciado interno.
                            .background(Color(hex: "#F7B958")) // Fondo naranja.
                            .foregroundColor(.white) // Texto blanco.
                            .cornerRadius(10) // Bordes redondeados.
                    }
                    .sheet(isPresented: $showAddStudent) {
                        AddStudentView()
                            .environment(\.managedObjectContext, context)
                    }
                    .accessibilityIdentifier("addStudentButton") // Identificador para pruebas.
                }
                .padding() // Espaciado alrededor de los botones.
            }
            .navigationTitle("Usuarios y Alumnos") // Título de la vista.
            .sheet(item: $selectedUser) { user in
                EditUserView(usuario: user)
                    .environment(\.managedObjectContext, context)
            }
            .sheet(item: $selectedStudent) { student in
                EditStudentView(student: student)
                    .environment(\.managedObjectContext, context)
            }
            .overlay(
                VStack {
                    if showToast {
                        ToastView(message: toastMessage, isError: isError)
                            .transition(.opacity)
                            .animation(.easeInOut, value: isExpanded)
                    }
                },
                alignment: .top
            )
        }
        .accessibilityIdentifier("adminUsersListView") // Identificador de accesibilidad para la vista principal.
    }

    // MARK: - Funciones auxiliares

    /// Filtra los usuarios según el texto de búsqueda.
    private var filteredUsers: [Usuario] {
        usuarios.filter {
            searchText.isEmpty || $0.nombre?.localizedCaseInsensitiveContains(searchText) == true
        }
    }

    /// Filtra los alumnos según el texto de búsqueda.
    private var filteredStudents: [Alumno] {
        alumnos.filter {
            searchText.isEmpty || $0.nombre?.localizedCaseInsensitiveContains(searchText) == true
        }
    }

    /// Elimina un usuario de Core Data.
    private func deleteUser(_ user: Usuario) {
        context.delete(user) // Elimina el usuario del contexto.
        saveChanges {
            showToast(message: "Usuario eliminado correctamente", isError: false) // Muestra un mensaje de éxito.
        }
    }

    /// Elimina un alumno de Core Data.
    private func deleteStudent(_ student: Alumno) {
        context.delete(student) // Elimina el alumno del contexto.
        saveChanges {
            showToast(message: "Alumno eliminado correctamente", isError: false) // Muestra un mensaje de éxito.
        }
    }

    /// Guarda los cambios en Core Data.
    private func saveChanges(completion: () -> Void) {
        do {
            try context.save() // Intenta guardar los cambios.
            completion() // Ejecuta la función de completitud si tiene éxito.
        } catch {
            showToast(message: "Error al guardar los cambios: \(error.localizedDescription)", isError: true) // Muestra un mensaje de error.
        }
    }

    /// Muestra un mensaje Toast.
    private func showToast(message: String, isError: Bool) {
        toastMessage = message
        self.isError = isError
        withAnimation {
            showToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                showToast = false
            }
        }
    }
}
/// Subvista para mostrar una lista de usuarios filtrados.
/// Esta sección incluye el encabezado y filas correspondientes a los usuarios encontrados.
struct UsersSection: View {
    let filteredUsers: [Usuario] // Lista de usuarios filtrados con base en el texto de búsqueda.
    let onUserSelected: (Usuario) -> Void // Closure que se llama al seleccionar un usuario.
    let onDelete: (Usuario) -> Void // Closure que se llama para eliminar un usuario.

    var body: some View {
        // Comprueba si hay usuarios filtrados disponibles para mostrar.
        if !filteredUsers.isEmpty {
            // Sección con un encabezado "Usuarios".
            Section(header: Text("Usuarios")) {
                // Itera sobre los usuarios filtrados para crear filas.
                ForEach(filteredUsers, id: \.id) { user in
                    // Vista personalizada para cada fila de usuario.
                    UserRowView(user: user) {
                        // Acción al seleccionar un usuario.
                        onUserSelected(user)
                    }
                    // Acciones disponibles al deslizar la fila (swipe actions).
                    .swipeActions {
                        // Botón para eliminar al usuario.
                        Button("Eliminar", role: .destructive) {
                            onDelete(user) // Llama al closure de eliminación.
                        }
                    }
                }
            }
        }
    }
}
/// Subvista para mostrar una lista de alumnos filtrados.
/// Esta sección incluye el encabezado y filas correspondientes a los alumnos encontrados.
struct StudentsSection: View {
    let filteredStudents: [Alumno] // Lista de alumnos filtrados con base en el texto de búsqueda.
    let onStudentSelected: (Alumno) -> Void // Closure que se llama al seleccionar un alumno.
    let onDelete: (Alumno) -> Void // Closure que se llama para eliminar un alumno.

    var body: some View {
        // Comprueba si hay alumnos filtrados disponibles para mostrar.
        if !filteredStudents.isEmpty {
            // Sección con un encabezado "Alumnos".
            Section(header: Text("Alumnos")) {
                // Itera sobre los alumnos filtrados para crear filas.
                ForEach(filteredStudents, id: \.id) { student in
                    // Vista personalizada para cada fila de alumno.
                    StudentRowView(student: student) {
                        // Acción al seleccionar un alumno.
                        onStudentSelected(student)
                    }
                    // Acciones disponibles al deslizar la fila (swipe actions).
                    .swipeActions {
                        // Botón para eliminar al alumno.
                        Button("Eliminar", role: .destructive) {
                            onDelete(student) // Llama al closure de eliminación.
                        }
                    }
                }
            }
        }
    }
}
