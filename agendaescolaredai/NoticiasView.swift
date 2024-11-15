//
//  NoticiasView.swift
//  agendaescolaredai
//
//  Created by Juan Antonio Sánchez Carrillo on 19/11/24.
//

import SwiftUI
import CoreData

/// Vista principal que muestra las últimas noticias agrupadas dentro de un contenedor.
struct NoticiasView: View {
    /// Usuario actual para personalizar o filtrar contenido.
    let currentUser: Usuario

    /// Maneja la pila de navegación.
    @State private var navigationPath = NavigationPath()

    /// FetchRequest para obtener las noticias desde Core Data, ordenadas por fecha de publicación (más recientes primero).
    @FetchRequest var noticias: FetchedResults<Noticia>

    /// Inicializador que configura el FetchRequest.
    /// - Parameter currentUser: Usuario actual que verá las noticias.
    init(currentUser: Usuario) {
        self.currentUser = currentUser
        _noticias = FetchRequest(
            entity: Noticia.entity(), // Entidad de noticias.
            sortDescriptors: [NSSortDescriptor(keyPath: \Noticia.fechaPublicacion, ascending: false)] // Ordenar por fecha descendente.
        )
    }

    /// Cuerpo de la vista principal.
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 0) {
                // Encabezado de la sección.
                Text("Últimas Noticias")
                    .font(.largeTitle) // Fuente grande para el título.
                    .fontWeight(.bold) // Estilo en negrita.
                    .padding(.horizontal) // Espaciado lateral.
                    .padding(.top, 10) // Espaciado superior.
                    .accessibilityIdentifier("noticiasTitle")

                // Contenedor de noticias con scroll.
                ScrollView {
                    VStack(spacing: 0) {
                        // Itera sobre las noticias y las muestra en el panel.
                        ForEach(noticias, id: \.id) { noticia in
                            NewsPanelItemView(noticia: noticia)
                                .accessibilityIdentifier("noticia_\(noticia.id ?? UUID())")
                            Divider()
                                .background(Color.gray.opacity(0.5)) // Separador entre noticias.
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(12) // Esquinas redondeadas.
                    .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2) // Sombra del contenedor.
                    .padding(.horizontal, 15)
                    .accessibilityIdentifier("noticiasScrollContainer")
                }

                Spacer()

                // Menú inferior fijo.
                HStack {
                    NavigationLink(destination: destinationForRole()) {
                        BottomTabItem(
                            imageName: currentUser.rol == "profesor" || currentUser.rol == "administrador" ? "teacherPerfilIcon" : "tutorPerfilIcon",
                            label: "Perfil", action: nil
                        )
                    }
                    .accessibilityIdentifier("noticiasTabPerfil")

                    Spacer()

                    NavigationLink(destination: CalendarView(usuario: currentUser)) {
                        BottomTabItem(imageName: "calendarIcon", label: "Calendario", action: nil)
                    }
                    .accessibilityIdentifier("noticiasTabCalendario")

                    Spacer()

                    NavigationLink(destination: ConversationsListView(currentUser: currentUser)) {
                        BottomTabItem(imageName: "contactIcon", label: "Contacto", action: nil)
                    }
                    .accessibilityIdentifier("noticiasTabContacto")

                    Spacer()

                    BottomTabItem(imageName: "notificationIcon", label: "Últimas Noticias", action: nil)
                        .accessibilityIdentifier("noticiasTabNoticias")
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
                .background(Color.white)
                .accessibilityIdentifier("noticiasBottomTabBar")
            }
            .navigationDestination(for: Alumno.self) { alumno in
                TutorAlumnoView(student: alumno)
            }
            .navigationDestination(for: String.self) { destination in
                switch destination {
                case "CalendarView":
                    CalendarView(usuario: currentUser)
                case "ConversationsListView":
                    ConversationsListView(currentUser: currentUser)
                default:
                    EmptyView() // Fallback para destinos no reconocidos.
                }
            }
        }
        .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))
    }

    /// Devuelve la vista de perfil correspondiente al rol del usuario.
    private func destinationForRole() -> some View {
        if currentUser.rol == "profesor" {
            return AnyView(TeacherProfileView(teacher: currentUser))
        } else if currentUser.rol == "tutor" {
            return AnyView(TutorProfileView(tutor: currentUser))
        } else {
            return AnyView(EmptyView())
        }
    }
}

/// Vista personalizada para representar cada noticia dentro del panel.
struct NewsPanelItemView: View {
    let noticia: Noticia

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(noticia.titulo?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Sin título")
                .font(.headline)
                .foregroundColor(.blue)
                .accessibilityIdentifier("noticiaTitulo")

            Text("Publicado por: \(noticia.autor?.nombre ?? "Desconocido")")
                .font(.subheadline)
                .foregroundColor(.gray)
                .accessibilityIdentifier("noticiaAutor")

            Text(noticia.contenido?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Sin contenido")
                .font(.body)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
                .accessibilityIdentifier("noticiaContenido")

            Text("Fecha: \(noticia.fechaPublicacion ?? Date(), formatter: dateFormatter)")
                .font(.footnote)
                .italic()
                .foregroundColor(.secondary)
                .accessibilityIdentifier("noticiaFecha")
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
