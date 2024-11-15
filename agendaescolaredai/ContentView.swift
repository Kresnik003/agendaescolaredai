//
//  ContentView.swift
//  agendaescolaredai
//
//  Created by Juan Antonio Sánchez Carrillo on 15/11/24.
//

import SwiftUI
import CoreData

/// Vista principal de la aplicación que actúa como controlador para mostrar diferentes pantallas según el estado de la sesión del usuario.
struct ContentView: View {
    // MARK: - Propiedades

    /// Estado que indica si el usuario ha iniciado sesión.
    @State private var isUserLoggedIn = false

    /// Propiedad que almacena al usuario actual logueado, o `nil` si no hay un usuario logueado.
    @State private var currentUser: Usuario? = nil

    // MARK: - Vista principal del contenido

    var body: some View {
        // Estructura condicional para mostrar contenido dependiendo del estado de inicio de sesión.
        if isUserLoggedIn {
            // Si el usuario está logueado, decide qué vista mostrar según el usuario actual.
            if let user = currentUser {
                // Evalúa el rol del usuario actual y muestra la vista correspondiente.
                switch user.rol {
                case "administrador":
                    // Muestra la vista del perfil de administrador.
                    AdminProfileView(admin: user)
                        .accessibilityIdentifier("AdminProfileView") // Identificador para pruebas de accesibilidad.
                case "profesor":
                    // Muestra la vista del perfil de profesor.
                    TeacherProfileView(teacher: user)
                        .accessibilityIdentifier("TeacherProfileView") // Identificador para pruebas de accesibilidad.
                case "tutor":
                    // Muestra la vista del perfil de tutor.
                    TutorProfileView(tutor: user)
                        .accessibilityIdentifier("TutorProfileView") // Identificador para pruebas de accesibilidad.
                default:
                    // En caso de que el rol no sea reconocido, muestra un mensaje de error.
                    Text("Rol desconocido. Contacta al administrador.")
                        .font(.headline) // Estilo de fuente destacado para el mensaje.
                        .foregroundColor(.red) // Color rojo para enfatizar el error.
                        .multilineTextAlignment(.center) // Alinea el texto al centro.
                        .accessibilityIdentifier("UnknownRoleMessage") // Identificador para pruebas de accesibilidad.
                }
            } else {
                // En caso de que `currentUser` sea `nil`, muestra un mensaje de error.
                Text("Error: No se pudo cargar el usuario actual.")
                    .font(.headline) // Estilo de fuente destacado para el mensaje.
                    .foregroundColor(.red) // Color rojo para indicar el error.
                    .multilineTextAlignment(.center) // Alinea el texto al centro.
                    .accessibilityIdentifier("CurrentUserError") // Identificador para pruebas de accesibilidad.
            }
        } else {
            // Si el usuario no está logueado, muestra la vista de inicio de sesión.
            LoginView(isUserLoggedIn: $isUserLoggedIn, currentUser: $currentUser)
                .accessibilityIdentifier("LoginView") // Identificador para pruebas de accesibilidad.
        }
    }
}
