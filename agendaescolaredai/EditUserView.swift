//
//  EditUserView.swift
//  agendaescolaredai
//
//  Created by Juan Antonio Sánchez Carrillo on 22/11/24.
//

import SwiftUI
import CoreData

/// Vista para editar un usuario existente.
struct EditUserView: View {
    @Environment(\.managedObjectContext) private var context // Contexto de Core Data.
    @Environment(\.dismiss) private var dismiss // Control para cerrar la vista.

    @State private var nombre: String // Estado para almacenar el nombre del usuario.
    @State private var email: String // Estado para almacenar el email del usuario.
    @State private var rol: String // Estado para almacenar el rol del usuario.
    @State private var contrasena: String // Estado para almacenar la contraseña del usuario.
    @State private var mostrarContrasena = false // Estado para controlar si la contraseña está visible.
    @State private var showPasswordAlert = false // Estado para mostrar la alerta de la nueva contraseña.

    private let roles = ["tutor", "profesor", "administrador"] // Opciones para el rol.

    let usuario: Usuario // Usuario a editar.

    /// Inicializador para configurar los estados iniciales con los datos del usuario.
    init(usuario: Usuario) {
        self.usuario = usuario
        _nombre = State(initialValue: usuario.nombre ?? "")
        _email = State(initialValue: usuario.email ?? "")
        _rol = State(initialValue: usuario.rol ?? "tutor")
        _contrasena = State(initialValue: usuario.contrasena ?? "")
    }

    var body: some View {
        NavigationView {
            Form {
                // Sección para editar la información personal del usuario.
                Section(header: Text("Información del Usuario")) {
                    // Campo para editar el nombre del usuario.
                    TextField("Nombre", text: $nombre)
                        .autocapitalization(.words)
                        .accessibilityIdentifier("editUserNameField")

                    // Campo para editar el email del usuario.
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .accessibilityIdentifier("editUserEmailField")
                }

                // Sección para gestionar la contraseña.
                Section(header: Text("Contraseña")) {
                    HStack {
                        if mostrarContrasena {
                            TextField("Contraseña", text: $contrasena) // Campo de texto visible.
                        } else {
                            SecureField("Contraseña", text: $contrasena) // Campo de texto oculto.
                        }

                        // Botón para alternar la visibilidad de la contraseña.
                        Button(action: {
                            mostrarContrasena.toggle()
                        }) {
                            Image(systemName: mostrarContrasena ? "eye.slash" : "eye")
                                .foregroundColor(.blue)
                        }
                        .accessibilityIdentifier("togglePasswordVisibility")
                    }

                    // Botón para generar una nueva contraseña segura.
                    Button(action: {
                        contrasena = generateSecurePassword()
                        showPasswordAlert = true
                    }) {
                        HStack {
                            Image(systemName: "key.fill")
                            Text("Generar Contraseña Segura")
                        }
                    }
                    .accessibilityIdentifier("generateSecurePasswordButton")
                }

                // Sección para seleccionar el rol del usuario.
                Section(header: Text("Rol")) {
                    Picker("Rol", selection: $rol) {
                        // Muestra las opciones de rol disponibles.
                        ForEach(roles, id: \.self) { role in
                            Text(role.capitalized)
                                .accessibilityIdentifier("\(role)PickerOption")
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .accessibilityIdentifier("editUserRolePicker")
                }
            }
            .navigationTitle("Editar Usuario") // Título de la vista.
            .toolbar {
                // Botón para guardar los cambios realizados.
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        saveChanges() // Llama a la función para guardar cambios.
                    }
                    .accessibilityIdentifier("editUserSaveButton")
                }

                // Botón para cancelar la edición.
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss() // Cierra la vista sin guardar.
                    }
                    .accessibilityIdentifier("editUserCancelButton")
                }
            }
            .alert(isPresented: $showPasswordAlert) {
                Alert(
                    title: Text("Nueva Contraseña Generada"),
                    message: Text("Contraseña: \(contrasena)\nCopia y entrega esta contraseña al usuario."),
                    dismissButton: .default(Text("Aceptar"))
                )
            }
        }
    }

    /// Guarda los cambios realizados en el usuario.
    private func saveChanges() {
        // Verifica que los campos obligatorios no estén vacíos.
        guard !nombre.isEmpty, !email.isEmpty, !contrasena.isEmpty else {
            print("Nombre, email o contraseña no pueden estar vacíos.")
            return
        }

        // Actualiza las propiedades del usuario con los valores editados.
        usuario.nombre = nombre
        usuario.email = email
        usuario.rol = rol
        usuario.contrasena = contrasena

        // Intenta guardar los cambios en Core Data.
        do {
            try context.save() // Guarda los cambios.
            dismiss() // Cierra la vista tras guardar.
        } catch {
            // Maneja errores en caso de fallo al guardar.
            print("Error al guardar los cambios del usuario: \(error.localizedDescription)")
        }
    }

    /// Genera una contraseña segura.
    private func generateSecurePassword() -> String {
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_+=-<>?"
        return String((0..<12).map { _ in characters.randomElement()! })
    }
}
