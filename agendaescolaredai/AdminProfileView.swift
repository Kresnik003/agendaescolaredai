//
//  AdminProfileView.swift
//  agendaescolaredai
//
//  Created by Juan Antonio Sánchez Carrillo on 16/11/24.
//

import SwiftUI

/// Vista de perfil del administrador, con opciones de gestión para todas las entidades principales.
struct AdminProfileView: View {
    // Propiedad que representa al usuario logueado como administrador.
    let admin: Usuario

    /// Maneja la navegación entre vistas.
    @State private var navigationPath = NavigationPath()
    @State private var needsUpdate = false // Estado compartido para actualizar.

    /// Cuerpo principal de la vista.
    var body: some View {
        // Contenedor de navegación principal utilizando `NavigationStack`.
        NavigationStack(path: $navigationPath) {
            VStack {
                // Encabezado de bienvenida.
                Text("¡Hola, \(admin.nombre ?? "Administrador")!")
                    .font(.largeTitle) // Aplica un estilo de título grande.
                    .bold() // Destaca el texto con negrita.
                    .padding() // Espaciado adicional alrededor del texto.
                    .accessibilityIdentifier("adminProfileGreeting") // Identificador para pruebas de accesibilidad.

                // Opciones principales organizadas en una cuadrícula flexible.
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 5) {
                    // Cada tarjeta representa una funcionalidad principal del administrador.

                    // Opción para administrar aulas.
                    SmallOptionCardView(imageName: "aulaIcon", title: "Administrar Aulas") {
                        navigationPath.append("AdminAulasListView")
                    }
                    .accessibilityIdentifier("adminAulasOption")

                    // Opción para administrar usuarios.
                    SmallOptionCardView(imageName: "userIcon", title: "Administrar Usuarios") {
                        navigationPath.append("AdminUsersListView")
                    }
                    .accessibilityIdentifier("adminUsersOption")

                    // Opción para administrar centros educativos.
                    SmallOptionCardView(imageName: "centroIcon", title: "Gestionar Centros") {
                        navigationPath.append("AdminCentrosListView")
                    }
                    .accessibilityIdentifier("adminCentrosOption")

                    // Opción para gestionar comunicaciones.
                    SmallOptionCardView(imageName: "commsIcon", title: "Mis Comunicaciones") {
                        navigationPath.append("AdminConversationsListView")
                    }
                    .accessibilityIdentifier("adminCommsOption")

                    // Opción para gestionar menús.
                    SmallOptionCardView(imageName: "menuIcon", title: "Gestionar Menús") {
                        navigationPath.append("AdminMenusListView")
                    }
                    .accessibilityIdentifier("adminMenusOption")

                    // Opción para gestionar noticias.
                    SmallOptionCardView(imageName: "newsIcon", title: "Gestionar Noticias") {
                        navigationPath.append("AdminNoticiasView")
                    }
                    .accessibilityIdentifier("adminNoticiasOptionCard")
                }
                .padding() // Espaciado adicional alrededor del grid.
                .accessibilityIdentifier("adminOptionsGrid") // Identificador para la cuadrícula de opciones.

                Spacer() // Agrega espacio flexible entre las opciones y la barra inferior.

                // Barra de navegación inferior con accesos rápidos a funcionalidades principales.
                HStack {
                    // Botón de perfil del administrador.
                    NavigationLink(destination: AdminProfileView(admin: admin)) {
                        BottomTabItem(imageName: "teacherPerfilIcon", label: "Perfil", action: nil)
                    }
                    .accessibilityIdentifier("adminTabProfile")

                    Spacer() // Espaciado entre los botones.

                    // Botón para el calendario.
                    NavigationLink(destination: CalendarView(usuario: admin)) {
                        BottomTabItem(imageName: "calendarIcon", label: "Calendario", action: nil)
                    }
                    .accessibilityIdentifier("adminTabCalendar")

                    Spacer() // Espaciado entre los botones.

                    // Botón para acceder a comunicaciones.
                    NavigationLink(destination: AdminConversationsListView(admin: admin)) {
                        BottomTabItem(imageName: "contactIcon", label: "Contacto", action: nil)
                    }
                    .accessibilityIdentifier("adminTabContact")

                    Spacer() // Espaciado entre los botones.

                    // Botón para notificaciones o últimas noticias.
                    NavigationLink(destination: NoticiasView(currentUser: admin)) {
                        BottomTabItem(imageName: "notificationIcon", label: "Últimas Noticias", action: nil)
                    }
                    .accessibilityIdentifier("adminTabNotifications")
                }
                .padding(.horizontal) // Espaciado lateral en la barra de navegación inferior.
                .padding(.bottom, 10) // Espaciado inferior para la barra.
                .accessibilityIdentifier("adminBottomNavBar")
            }
            .padding() // Espaciado adicional en todo el contenido principal.
            .navigationBarTitleDisplayMode(.inline) // Alineación en línea para el título de navegación.
            .navigationDestination(for: String.self) { destination in
                // Controla la navegación según el destino seleccionado.
                switch destination {
                case "AdminAulasListView":
                    AdminAulasListView() // Vista de gestión de aulas.
                case "AdminUsersListView":
                    AdminUsersListView() // Vista de gestión de usuarios.
                case "AdminCentrosListView":
                    AdminCentrosListView()
                case "AdminConversationsListView":
                    AdminConversationsListView(admin: admin) // Vista de comunicaciones.
                case "AdminMenusListView":
                    AdminMenusListView() // Vista de gestión de menús.
                case "AdminNoticiasView":
                    AdminNoticiasView(usuarioActual: admin) // Vista de gestión de noticias.
                default:
                    EmptyView() // Vista vacía como fallback para destinos no definidos.
                }
            }
        }
    }
}
