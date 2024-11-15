//
//  AdminConversationsListView.swift
//  agendaescolaredai
//
//  Created by Juan Antonio Sánchez Carrillo on 22/11/24.
//

import SwiftUI
import CoreData

/// Vista diseñada para que los administradores gestionen sus comunicaciones dentro de la aplicación.
/// Sirve como contenedor que reutiliza la funcionalidad de la vista `ConversationsListView` para listar y manejar mensajes.
struct AdminConversationsListView: View {
    /// Usuario logueado como administrador.
    let admin: Usuario

    /// Cuerpo principal de la vista.
    var body: some View {
        // Presenta la vista `ConversationsListView` pasando el usuario administrador como argumento.
        ConversationsListView(currentUser: admin)
            .navigationTitle("Mis Comunicaciones") // Título de la navegación en la barra superior.
            .accessibilityIdentifier("adminConversationsListView") // Identificador de accesibilidad para pruebas.
    }
}
