//
//  TeacherProfileView.swift
//  agendaescolaredai
//
//  Created by Juan Antonio Sánchez Carrillo on 16/11/24.
//

import SwiftUI
import CoreData

/// Vista principal del perfil del profesor.
/// Ofrece un menú visual con opciones para gestionar aulas, alumnos, registros, comunicaciones y galería de fotos.
struct TeacherProfileView: View {
    /// Usuario logueado como profesor.
    let teacher: Usuario

    /// Maneja la pila de navegación para desplazarse entre vistas.
    @State private var navigationPath = NavigationPath()

    var body: some View {
        // Contenedor principal con capacidad de navegación utilizando `NavigationStack`.
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 20) { // Disposición vertical con espaciado entre elementos.
                // Encabezado con saludo personalizado para el profesor.
                Text("Hola, \(teacher.nombre ?? "Profesor")")
                    .font(.title) // Fuente grande para destacar el saludo.
                    .bold() // Aplica negrita al texto.
                    .foregroundColor(.black) // Texto en color negro.
                    .accessibilityIdentifier("teacherWelcomeText") // Identificador para pruebas de accesibilidad.

                // Grid con las opciones principales.
                opcionesGrid
                    .padding(.horizontal) // Espaciado lateral para el grid.

                Spacer() // Espacio flexible que empuja el contenido hacia la parte superior.

                // Barra de navegación inferior.
                barraNavegacionInferior
            }
            .padding() // Espaciado general en el contenido principal.
            .navigationBarTitleDisplayMode(.inline) // Título alineado en línea con la barra de navegación.
            .navigationDestination(for: String.self) { destino in
                // Controla la navegación según el destino seleccionado.
                switch destino {
                case "AulasListView":
                    // Navega a la vista de lista de aulas.
                    AulasListView(profesor: teacher)
                case "ProfesorAlumnosListView":
                    // Navega a la vista de lista de alumnos del profesor.
                    ProfesorAlumnosListView(profesor: teacher)
                case "RegistrosListView":
                    // Navega a la vista de registros diarios.
                    RegistrosListView(teacher: teacher)
                case "TeacherGalleryView":
                    // Navega a la vista de galería de fotos.
                    TeacherGalleryView()
                case "CalendarView":
                    // Navega a la vista de calendario.
                    CalendarView(usuario: teacher)
                case "ConversationsListView":
                    // Navega a la vista de lista de conversaciones.
                    ConversationsListView(currentUser: teacher)
                default:
                    // Muestra una vista vacía si el destino no es reconocido.
                    EmptyView()
                }
            }
        }
    }

    /// Grid que presenta las opciones principales del perfil del profesor.
    private var opcionesGrid: some View {
        // Disposición en grid con dos columnas flexibles.
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
            // Tarjeta de opción para gestionar aulas.
            OptionCardView(imageName: "aulaIcon", title: "Mis Aulas") {
                navigationPath.append("AulasListView") // Navega a la lista de aulas.
            }
            .accessibilityIdentifier("aulasOption") // Identificador para pruebas de accesibilidad.

            // Tarjeta de opción para gestionar alumnos.
            OptionCardView(imageName: "studentsIcon", title: "Mis Alumnos") {
                navigationPath.append("ProfesorAlumnosListView") // Navega a la lista de alumnos.
            }
            .accessibilityIdentifier("alumnosOption") // Identificador para pruebas de accesibilidad.

            // Tarjeta de opción para gestionar registros diarios.
            OptionCardView(imageName: "registryIcon", title: "Mi Registro") {
                navigationPath.append("RegistrosListView") // Navega a los registros diarios.
            }
            .accessibilityIdentifier("registrosOption") // Identificador para pruebas de accesibilidad.

            // Tarjeta de opción para acceder a la galería de fotos.
            OptionCardView(imageName: "iconoGaleria", title: "Galería de Fotos") {
                navigationPath.append("TeacherGalleryView") // Navega a la galería de fotos.
            }
            .accessibilityIdentifier("teacherGalleryOption") // Identificador para pruebas de accesibilidad.
        }
    }

    /// Barra de navegación inferior con accesos rápidos.
    private var barraNavegacionInferior: some View {
        // Disposición horizontal para los elementos de la barra.
        HStack {
            // Botón de perfil, redirige a la vista actual del perfil del profesor.
            NavigationLink(destination: TeacherProfileView(teacher: teacher)) {
                BottomTabItem(imageName: "teacherPerfilIcon", label: "Perfil", action: nil)
            }
            .accessibilityIdentifier("perfilTab") // Identificador para pruebas de accesibilidad.

            Spacer() // Espaciado flexible entre los elementos.

            // Botón de calendario.
            NavigationLink(destination: CalendarView(usuario: teacher)) {
                BottomTabItem(imageName: "calendarIcon", label: "Calendario", action: nil)
            }
            .accessibilityIdentifier("calendarioTab") // Identificador para pruebas de accesibilidad.

            Spacer() // Espaciado flexible entre los elementos.

            // Botón de contacto.
            NavigationLink(destination: ConversationsListView(currentUser: teacher)) {
                BottomTabItem(imageName: "contactIcon", label: "Contacto", action: nil)
            }
            .accessibilityIdentifier("contactoTab") // Identificador para pruebas de accesibilidad.

            Spacer() // Espaciado flexible entre los elementos.

            // Botón de notificaciones.
            NavigationLink(destination: NoticiasView(currentUser: teacher)) {
                BottomTabItem(imageName: "notificationIcon", label: "Últimas Noticias", action: nil)
            }
            .accessibilityIdentifier("notificacionesTab") // Identificador para pruebas de accesibilidad.
        }
        .padding(.horizontal) // Espaciado lateral en la barra.
        .padding(.bottom, 10) // Espaciado inferior en la barra.
    }
}
