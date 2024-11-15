//
//  AddUserView.swift
//  agendaescolaredai
//
//  Created by Juan Antonio Sánchez Carrillo on 22/11/24.
//

import SwiftUI
import CoreData

/// Vista para agregar un nuevo usuario al sistema.
/// Proporciona un formulario que permite capturar información básica del usuario, como nombre, correo electrónico, rol y contraseña.
/// Los datos introducidos se almacenan en la base de datos utilizando Core Data.
struct AddUserView: View {
    // Inyección del contexto de Core Data desde el entorno.
    // Este contexto se utiliza para realizar operaciones CRUD en la base de datos.
    @Environment(\.managedObjectContext) private var context

    // Controlador para cerrar la vista actual.
    @Environment(\.dismiss) private var dismiss

    // Estados para capturar y manejar los datos introducidos por el usuario.
    @State private var nombre: String = "" // Almacena el nombre del usuario.
    @State private var email: String = "" // Almacena el correo electrónico del usuario.
    @State private var rol: String = "tutor" // Almacena el rol seleccionado para el usuario.
    @State private var contrasena: String = "" // Almacena la contraseña generada para el usuario.
    @State private var showGeneratedPassword: Bool = false // Controla si se muestra la contraseña generada.

    // Opciones disponibles para el rol del usuario.
    private let roles = ["tutor", "profesor", "administrador"]

    /// Cuerpo principal de la vista.
    var body: some View {
        // Contenedor de navegación para organizar la interfaz.
        NavigationView {
            // Formulario con secciones para capturar datos del usuario.
            Form {
                // SECCIÓN: Información del Usuario.
                Section(header: Text("Información del Usuario")) {
                    // Campo de texto para capturar el nombre del usuario.
                    TextField("Nombre", text: $nombre)
                        .autocapitalization(.words) // Capitaliza automáticamente cada palabra.
                        .accessibilityIdentifier("nombreTextField") // Identificador para pruebas de accesibilidad.

                    // Campo de texto para capturar el correo electrónico del usuario.
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress) // Configura el teclado para ingresar direcciones de correo electrónico.
                        .accessibilityIdentifier("emailTextField") // Identificador para pruebas de accesibilidad.
                }

                // SECCIÓN: Selección del Rol.
                Section(header: Text("Rol")) {
                    // Selector de rol utilizando un picker segmentado.
                    Picker("Rol", selection: $rol) {
                        // Muestra las opciones disponibles para el rol.
                        ForEach(roles, id: \.self) { role in
                            Text(role.capitalized) // Capitaliza y muestra cada opción de rol.
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle()) // Estilo segmentado para el picker.
                    .accessibilityIdentifier("rolPicker") // Identificador para pruebas de accesibilidad.
                }

                // SECCIÓN: Contraseña.
                Section(header: Text("Contraseña")) {
                    // Campo seguro para mostrar la contraseña generada.
                    SecureField("Contraseña Generada", text: $contrasena)
                        .accessibilityIdentifier("contrasenaSecureField") // Identificador para pruebas de accesibilidad.

                    // Botón para generar una contraseña segura aleatoria.
                    Button(action: generateSecurePassword) {
                        HStack {
                            Image(systemName: "key.fill") // Icono de llave.
                            Text("Generar Contraseña Segura") // Texto del botón.
                        }
                    }
                    .accessibilityIdentifier("generarContrasenaButton") // Identificador para pruebas de accesibilidad.

                    // Muestra la contraseña generada temporalmente.
                    if showGeneratedPassword {
                        Text("Contraseña Generada: \(contrasena)")
                            .font(.caption) // Texto de menor tamaño.
                            .foregroundColor(.green) // Color verde para indicar éxito.
                            .padding(.top, 5) // Espaciado superior.
                            .accessibilityIdentifier("contrasenaGeneradaText") // Identificador para pruebas de accesibilidad.
                    }
                }
            }
            .navigationTitle("Agregar Usuario") // Establece el título de la pantalla.
            .toolbar {
                // BOTÓN: Guardar Usuario.
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        saveUser() // Llama a la función que guarda el usuario en Core Data.
                    }
                    .accessibilityIdentifier("guardarButton") // Identificador para pruebas de accesibilidad.
                }

                // BOTÓN: Cancelar.
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss() // Cierra la vista actual sin realizar cambios.
                    }
                    .accessibilityIdentifier("cancelarButton") // Identificador para pruebas de accesibilidad.
                }
            }
        }
    }

    /// Función para guardar un nuevo usuario en Core Data.
    private func saveUser() {
        // Verifica que los campos obligatorios no estén vacíos.
        guard !nombre.isEmpty, !email.isEmpty, !contrasena.isEmpty else {
            print("Nombre, email o contraseña no pueden estar vacíos.")
            return
        }

        // Crea un nuevo objeto `Usuario` en el contexto de Core Data.
        let nuevoUsuario = Usuario(context: context)
        nuevoUsuario.id = UUID() // Genera un identificador único para el usuario.
        nuevoUsuario.nombre = nombre // Asigna el nombre ingresado.
        nuevoUsuario.email = email // Asigna el correo electrónico ingresado.
        nuevoUsuario.rol = rol // Asigna el rol seleccionado.
        nuevoUsuario.contrasena = contrasena // Asigna la contraseña generada.

        // Intenta guardar el contexto con los cambios realizados.
        do {
            try context.save() // Guarda los cambios en Core Data.
            dismiss() // Cierra la vista tras guardar el usuario.
        } catch {
            // Maneja cualquier error que ocurra al intentar guardar los datos.
            print("Error al guardar el usuario: \(error.localizedDescription)")
        }
    }

    /// Genera una contraseña segura aleatoria para el usuario.
    private func generateSecurePassword() {
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_+[]{}|;:,.<>?/~`-=" // Conjunto de caracteres disponibles.
        let passwordLength = 12 // Longitud de la contraseña generada.
        contrasena = String((0..<passwordLength).map { _ in characters.randomElement()! }) // Genera una contraseña aleatoria.
        showGeneratedPassword = true // Muestra la contraseña generada.

        // Oculta la contraseña generada después de 5 segundos.
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            showGeneratedPassword = false // Oculta la contraseña generada automáticamente.
        }
    }
}
