//
//  TutorProfileView.swift
//  agendaescolaredai
//
//  Created by Juan Antonio Sánchez Carrillo on 16/11/24.
//

import SwiftUI
import CoreData

/// Vista principal del perfil del tutor.
/// Permite listar a los alumnos asignados al tutor, acceder a su información detallada y navegar a la galería de fotos.
/// Proporciona una interfaz sencilla para interactuar con los elementos relacionados con el rol de tutor.
struct TutorProfileView: View {
    /// Usuario logueado como tutor.
    let tutor: Usuario

    /// Maneja la pila de navegación para desplazarse entre diferentes vistas.
    @State private var navigationPath = NavigationPath()

    /// `FetchRequest` para obtener los alumnos asociados al tutor desde Core Data.
    @FetchRequest var alumnos: FetchedResults<Alumno>

    /// `FetchRequest` para contar el número total de fotos disponibles en la galería.
    @FetchRequest(
        entity: Foto.entity(),
        sortDescriptors: []
    ) var fotos: FetchedResults<Foto>

    /// Inicializador que configura los `FetchRequest` para filtrar los alumnos asignados al tutor.
    /// - Parameter tutor: Instancia del usuario con rol de tutor.
    init(tutor: Usuario) {
        self.tutor = tutor
        _alumnos = FetchRequest(
            entity: Alumno.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Alumno.nombre, ascending: true)],
            predicate: NSPredicate(format: "tutor == %@", tutor)
        )
    }

    /// Cuerpo principal de la vista.
    var body: some View {
        // Contenedor principal con navegación.
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 20) {
                // Mensaje de bienvenida personalizado para el tutor.
                Text("Hola, \(tutor.nombre ?? "Tutor")")
                    .font(.title)
                    .bold()
                    .foregroundColor(.black)
                    .accessibilityIdentifier("tutorProfileGreeting")

                // Contenedor desplazable que agrupa los botones principales.
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        alumnosView // Lista de alumnos asignados.
                        galeriaView // Botón para acceder a la galería.
                    }
                    .padding()
                }

                Spacer() // Espaciado flexible que ajusta el contenido hacia la parte superior.

                // Barra de navegación inferior con accesos rápidos.
                barraNavegacionInferior
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Alumno.self) { alumno in
                // Navegación a la vista de información detallada del alumno.
                TutorAlumnoView(student: alumno)
                    .accessibilityIdentifier("tutorAlumnoView")
            }
            .navigationDestination(for: String.self) { destino in
                // Navegación a las vistas específicas según el destino.
                switch destino {
                case "TutorGalleryView":
                    TutorGalleryView()
                        .accessibilityIdentifier("tutorGalleryView")
                case "CalendarView":
                    CalendarView(usuario: tutor)
                        .accessibilityIdentifier("calendarView")
                case "ConversationsListView":
                    ConversationsListView(currentUser: tutor)
                        .accessibilityIdentifier("conversationsListView")
                default:
                    EmptyView()
                        .accessibilityIdentifier("emptyView")
                }
            }
            .accessibilityIdentifier("tutorProfileView")
        }
    }

    /// Vista que lista a los alumnos asignados al tutor.
    private var alumnosView: some View {
        ForEach(alumnos, id: \.id) { alumno in
            Button(action: {
                navigationPath.append(alumno) // Navega a la vista detallada del alumno.
            }) {
                VStack(spacing: 8) {
                    // Imagen del alumno, si está disponible.
                    if let imageName = alumno.imagen, let uiImage = UIImage(named: imageName) {
                        alumnoImageView(uiImage: uiImage)
                    } else {
                        // Imagen predeterminada si no hay una asignada.
                        placeholderImageView
                    }
                    Text(alumno.nombre ?? "Sin Nombre")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .accessibilityIdentifier("alumnoNombre_\(alumno.nombre ?? "SinNombre")")
                    Text(alumno.aula?.nombre ?? "Sin Aula")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .accessibilityIdentifier("alumnoAula_\(alumno.aula?.nombre ?? "SinAula")")
                }
            }
            .accessibilityIdentifier("alumnoButton_\(alumno.nombre ?? "default")")
        }
    }

    /// Vista que proporciona acceso a la galería de fotos.
    private var galeriaView: some View {
        Button(action: {
            navigationPath.append("TutorGalleryView") // Navega a la galería.
        }) {
            VStack(spacing: 8) {
                if let galImage = UIImage(named: "iconoGaleria") {
                    alumnoImageView(uiImage: galImage) // Muestra el ícono de la galería.
                } else {
                    placeholderImageView // Muestra un ícono predeterminado si no hay imagen.
                }
                Text("Galería de Fotos")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .accessibilityIdentifier("galleryTitle")
                Text("Total: \(fotos.count) fotos")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .accessibilityIdentifier("galleryTotalFotos")
            }
            .accessibilityIdentifier("tutorGalleryButton")
        }
    }

    /// Barra de navegación inferior que permite acceder rápidamente a las funcionalidades principales.
    private var barraNavegacionInferior: some View {
        HStack {
            NavigationLink(destination: TutorProfileView(tutor: tutor)) {
                BottomTabItem(imageName: "tutorPerfilIcon", label: "Perfil", action: nil)
            }
            .transaction { $0.animation = nil }
            .accessibilityIdentifier("perfilButton")

            Spacer()

            NavigationLink(destination: CalendarView(usuario: tutor)) {
                BottomTabItem(imageName: "calendarIcon", label: "Calendario", action: nil)
            }
            .transaction { $0.animation = nil }
            .accessibilityIdentifier("calendarioButton")

            Spacer()

            NavigationLink(destination: ConversationsListView(currentUser: tutor)) {
                BottomTabItem(imageName: "contactIcon", label: "Contacto", action: nil)
            }
            .transaction { $0.animation = nil }
            .accessibilityIdentifier("contactoButton")

            Spacer()

            NavigationLink(destination: NoticiasView(currentUser: tutor)) {
                BottomTabItem(imageName: "notificationIcon", label: "Últimas Noticias", action: nil)
            }
            .transaction { $0.animation = nil }
            .accessibilityIdentifier("notificacionesButton")
        }
        .padding(.horizontal)
        .padding(.bottom, 10)
    }

    /// Vista para mostrar imágenes de alumnos o galería.
    private func alumnoImageView(uiImage: UIImage) -> some View {
        Image(uiImage: uiImage)
            .resizable()
            .scaledToFill()
            .frame(width: 170, height: 170)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "#7BB2E0"), lineWidth: 3))
            .shadow(radius: 5)
    }

    /// Vista para mostrar un marcador de posición en caso de no haber imagen disponible.
    private var placeholderImageView: some View {
        Image(systemName: "person.fill")
            .resizable()
            .scaledToFit()
            .frame(width: 170, height: 170)
            .foregroundColor(.gray)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(radius: 5)
    }
}
