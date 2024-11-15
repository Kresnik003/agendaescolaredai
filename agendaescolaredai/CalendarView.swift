//
//  CalendarView.swift
//  agendaescolaredai
//
//  Created by Juan Antonio Sánchez Carrillo on 17/11/24.
//

import SwiftUI
import CoreData

/// Vista del calendario que permite seleccionar una fecha y ver el menú correspondiente.
struct CalendarView: View {
    @State private var selectedDate = Date() // Estado que almacena la fecha seleccionada.
    let usuario: Usuario // Usuario actual para personalizar las vistas según su rol.
    
    /// FetchRequest para obtener los menús almacenados en Core Data, ordenados por fecha en orden ascendente.
    @FetchRequest(
        entity: Menu.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Menu.fecha, ascending: true)]
    ) var menus: FetchedResults<Menu>

    @State private var navigationPath = NavigationPath() // Pila de navegación para controlar el desplazamiento entre vistas.

    var body: some View {
        // Contenedor principal de navegación.
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 20) { // Contenedor principal con espaciado uniforme entre elementos.
                // Título de la vista.
                Text("Menú Mensual Escolar")
                    .font(.title) // Estilo de fuente para el título.
                    .bold() // Aplica negrita al título.
                    .padding(.top, 10) // Espaciado superior.
                    .accessibilityIdentifier("calendarTitle") // Identificador para pruebas de accesibilidad.

                Spacer(minLength: 15) // Espaciado adicional.

                // Selector de fecha.
                DatePicker("", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.graphical) // Configura el estilo gráfico para el selector.
                    .environment(\.locale, Locale(identifier: "es_ES")) // Configura el idioma del calendario.
                    .padding(.horizontal) // Añade espaciado horizontal.
                    .frame(maxHeight: 300) // Define un tamaño máximo para el selector.
                    .accessibilityIdentifier("datePicker") // Identificador de accesibilidad.

                Spacer(minLength: 30) // Espaciado adicional.

                // Verifica si existe un menú para la fecha seleccionada y lo muestra, o muestra un mensaje.
                if let menu = menus.first(where: { Calendar.current.isDate($0.fecha ?? Date(), inSameDayAs: selectedDate) }) {
                    // Si se encuentra un menú, muestra los detalles del menú.
                    MenuDetailsIconsView(menu: menu)
                        .padding(.horizontal)
                        .transition(.opacity) // Transición suave al aparecer.
                        .accessibilityIdentifier("menuDetailsView") // Identificador de accesibilidad.
                } else {
                    // Si no hay menú para la fecha seleccionada, muestra un mensaje en rojo.
                    Text("No hay menú para la fecha seleccionada.")
                        .foregroundColor(.red) // Destaca el mensaje en color rojo.
                        .font(.headline) // Estilo de fuente destacado.
                        .padding(.horizontal)
                        .accessibilityIdentifier("noMenuMessage") // Identificador de accesibilidad.
                }

                Spacer() // Empuja los elementos hacia arriba dejando espacio inferior.

                // Barra de navegación inferior.
                HStack {
                    // Botón para ir al perfil del usuario.
                    BottomTabItem(
                        imageName: usuario.rol == "profesor" || usuario.rol == "administrador" ? "teacherPerfilIcon" : "tutorPerfilIcon",
                        label: "Perfil"
                    ) {
                        navigationPath.append("PerfilView") // Navega a la vista de perfil.
                    }
                    .accessibilityIdentifier("profileTabButton") // Identificador de accesibilidad.

                    Spacer() // Espaciado entre botones.

                    // Botón para permanecer en el calendario.
                    BottomTabItem(imageName: "calendarIcon", label: "Calendario") {
                        // Ya estamos en esta vista, no se realiza ninguna acción.
                    }
                    .accessibilityIdentifier("calendarTabButton") // Identificador de accesibilidad.

                    Spacer()

                    // Botón para acceder a la lista de contactos o conversaciones.
                    BottomTabItem(imageName: "contactIcon", label: "Contacto") {
                        navigationPath.append("ConversationsListView") // Navega a la lista de conversaciones.
                    }
                    .accessibilityIdentifier("contactTabButton") // Identificador de accesibilidad.

                    Spacer()

                    // Botón para futuras notificaciones.
                    BottomTabItem(imageName: "notificationIcon", label: "Notificación") {
                        // Acción pendiente para implementación futura.
                    }
                    .accessibilityIdentifier("notificationTabButton") // Identificador de accesibilidad.
                }
                .padding(.horizontal) // Espaciado lateral para la barra.
                .padding(.bottom, 10) // Espaciado inferior adicional.
                .accessibilityIdentifier("bottomNavigationBar") // Identificador de la barra.
            }
            .background(Color.white) // Fondo blanco para la vista.
            .navigationBarTitleDisplayMode(.inline) // El título de la barra se alinea en línea con los elementos de navegación.
            .navigationBarBackButtonHidden(false) // Habilita el botón de retroceso.
            .navigationDestination(for: String.self) { destination in
                // Controla la navegación según el destino seleccionado.
                switch destination {
                case "PerfilView":
                    perfilView() // Navega a la vista de perfil adecuada según el rol.
                case "ConversationsListView":
                    ConversationsListView(currentUser: usuario) // Navega a la lista de conversaciones.
                default:
                    EmptyView() // Fallback para destinos desconocidos.
                }
            }
        }
    }

    /// Devuelve la vista de perfil adecuada según el rol del usuario.
    private func perfilView() -> some View {
        switch usuario.rol {
        case "profesor":
            return AnyView(TeacherProfileView(teacher: usuario)) // Vista para el perfil del profesor.
        case "tutor":
            return AnyView(TutorProfileView(tutor: usuario)) // Vista para el perfil del tutor.
        default:
            return AnyView(TeacherProfileView(teacher: usuario)) // Fallback al perfil de profesor.
        }
    }
}

/// Vista que muestra los detalles del menú utilizando iconos y texto.
struct MenuDetailsIconsView: View {
    let menu: Menu // Menú que se va a mostrar.

    var body: some View {
        VStack(alignment: .leading, spacing: 15) { // Contenedor principal para los detalles.
            // Título de los detalles.
            HStack {
                Text("🍽️ Menú del Día")
                    .font(.title2) // Estilo del título.
                    .bold() // Negrita para destacar.
                    .accessibilityIdentifier("menuTitle") // Identificador de accesibilidad.
                Spacer()
            }

            // Detalles del menú organizados en filas con iconos.
            HStack {
                menuIcon("desayunoIcon", title: "Desayuno", value: menu.desayuno)
                menuIcon("tentempieIcon", title: "Tentempié", value: menu.tentempie)
            }

            HStack {
                menuIcon("primerPlatoIcon", title: "1° Plato", value: menu.primerPlato)
                menuIcon("segundoPlatoIcon", title: "2° Plato", value: menu.segundoPlato)
            }

            HStack {
                menuIcon("postreIcon", title: "Postre", value: menu.postre)
            }
        }
        .padding() // Espaciado interno.
        .background(Color(.secondarySystemBackground)) // Fondo claro.
        .cornerRadius(12) // Bordes redondeados.
        .shadow(radius: 5) // Sombra para resaltar el contenedor.
        .accessibilityIdentifier("menuDetailsContainer") // Identificador de accesibilidad.
    }

    /// Crea un componente con un icono y texto asociado al menú.
    private func menuIcon(_ imageName: String, title: String, value: String?) -> some View {
        HStack(spacing: 8) {
            Image(imageName) // Icono del menú.
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40) // Tamaño fijo.
                .accessibilityIdentifier("\(title.lowercased())Icon")

            VStack(alignment: .leading) {
                Text(title) // Título del componente.
                    .font(.headline)
                    .accessibilityIdentifier("\(title.lowercased())Title")
                Text(value ?? "Sin información") // Valor o texto predeterminado.
                    .foregroundColor(.blue) // Color azul.
                    .font(.subheadline) // Fuente secundaria.
                    .accessibilityIdentifier("\(title.lowercased())Value")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading) // Alineación a la izquierda.
        .accessibilityIdentifier("\(title.lowercased())Container")
    }
}
