//
//  ConversationsListView.swift
//  agendaescolaredai
//
//  Created by Juan Antonio Sánchez Carrillo on 18/11/24.
//

import SwiftUI
import CoreData

/// Vista para mostrar la lista de conversaciones del usuario actual.
struct ConversationsListView: View {
    let currentUser: Usuario // Usuario actualmente logueado.

    // FetchRequest para recuperar los mensajes asociados al usuario desde Core Data.
    @FetchRequest private var mensajes: FetchedResults<Mensaje>

    @State private var searchText = "" // Texto de búsqueda.
    @State private var isShowingNewMessageView = false // Controla si se muestra la vista para iniciar nueva conversación.

    /// Inicializador que configura el FetchRequest para filtrar mensajes.
    /// - Parameter currentUser: Usuario logueado actualmente.
    init(currentUser: Usuario) {
        self.currentUser = currentUser

        // Predicado para obtener mensajes donde el usuario es remitente o destinatario.
        let predicate = NSPredicate(format: "remitente == %@ OR destinatario == %@", currentUser, currentUser)
        _mensajes = FetchRequest(
            entity: Mensaje.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Mensaje.fecha, ascending: false)],
            predicate: predicate
        )
    }

    var body: some View {
        NavigationView {
            VStack {
                // Barra de búsqueda.
                CustomSearchBar(text: $searchText)
                    .accessibilityIdentifier("conversationsSearchBar")

                // Lista de conversaciones.
                List {
                    // Agrupa los mensajes por usuario.
                    let groupedMessages = getGroupedMessages()
                    // Filtra y ordena los usuarios según el texto de búsqueda y la fecha del último mensaje.
                    let sortedUsers = getSortedUsers(by: groupedMessages)

                    // Muestra las conversaciones en la lista.
                    ForEach(sortedUsers, id: \.self) { user in
                        if let latestMessage = groupedMessages[user] {
                            // Navega a la vista de chat al seleccionar una conversación.
                            NavigationLink(destination: ChatView(currentUser: currentUser, otherUser: user)) {
                                // Fila que muestra información básica de la conversación.
                                ConversationRow(user: user, latestMessage: latestMessage, isUnread: isMessageUnread(latestMessage))
                                    .accessibilityIdentifier("conversationRow_\(user.nombre ?? "unknown")")
                            }
                        }
                    }
                }
                .accessibilityIdentifier("conversationsList")
            }
            .navigationTitle("Conversaciones")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Botón "+" en la barra de navegación.
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isShowingNewMessageView = true
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.blue)
                            .accessibilityIdentifier("newConversationButton")
                    }
                }
            }
            .sheet(isPresented: $isShowingNewMessageView) {
                NewMessageView(currentUser: currentUser, isShowingNewMessageView: $isShowingNewMessageView)
            }
        }
        .accessibilityIdentifier("conversationsNavigationView")
    }

    /// Agrupa los mensajes por usuario y selecciona el último mensaje.
    private func getGroupedMessages() -> [Usuario: Mensaje] {
        var groupedMessages: [Usuario: Mensaje] = [:]

        for mensaje in mensajes {
            guard let otherUser = mensaje.remitente == currentUser ? mensaje.destinatario : mensaje.remitente else {
                continue
            }

            if let existingMessage = groupedMessages[otherUser],
               let existingDate = existingMessage.fecha,
               let currentDate = mensaje.fecha,
               currentDate <= existingDate {
                continue
            }

            groupedMessages[otherUser] = mensaje
        }

        return groupedMessages
    }

    /// Ordena los usuarios por la fecha del último mensaje asociado y aplica el filtro de búsqueda.
    private func getSortedUsers(by groupedMessages: [Usuario: Mensaje]) -> [Usuario] {
        groupedMessages.keys.filter {
            searchText.isEmpty || ($0.nombre?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
        .sorted {
            let date1 = groupedMessages[$0]?.fecha ?? Date.distantPast
            let date2 = groupedMessages[$1]?.fecha ?? Date.distantPast
            return date1 > date2
        }
    }

    /// Comprueba si el último mensaje de una conversación está sin leer.
    private func isMessageUnread(_ message: Mensaje) -> Bool {
        return message.destinatario == currentUser && !message.leido
    }
}

/// Vista para iniciar una nueva conversación.
struct NewMessageView: View {
    let currentUser: Usuario // Usuario actual.
    @Binding var isShowingNewMessageView: Bool // Controla si se muestra esta vista.
    @State private var searchText = "" // Texto de búsqueda.
    @State private var selectedUser: Usuario? // Usuario seleccionado.
    @State private var firstMessageText = "" // Texto del mensaje inicial.

    // FetchRequest para obtener los usuarios disponibles según el rol del usuario actual.
    @FetchRequest private var usuarios: FetchedResults<Usuario>

    /// Inicializador para configurar el FetchRequest según el rol del usuario.
    init(currentUser: Usuario, isShowingNewMessageView: Binding<Bool>) {
        self.currentUser = currentUser
        self._isShowingNewMessageView = isShowingNewMessageView

        // Predicado para filtrar usuarios según el rol del usuario actual.
        let predicate: NSPredicate
        if currentUser.rol == "tutor" {
            predicate = NSPredicate(format: "rol == 'profesor' OR rol == 'administrador'")
        } else {
            predicate = NSPredicate(value: true) // Muestra todos los usuarios.
        }

        _usuarios = FetchRequest(
            entity: Usuario.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Usuario.nombre, ascending: true)],
            predicate: predicate
        )
    }

    var body: some View {
        NavigationView {
            VStack {
                // Barra de búsqueda para filtrar usuarios.
                CustomSearchBar(text: $searchText, placeholder: "Buscar usuarios...")
                    .accessibilityIdentifier("newMessageSearchBar")

                // Lista de usuarios disponibles para iniciar conversación.
                List {
                    ForEach(usuarios.filter {
                        searchText.isEmpty || ($0.nombre?.localizedCaseInsensitiveContains(searchText) ?? false)
                    }, id: \.id) { user in
                        Button(action: {
                            selectedUser = user
                        }) {
                            HStack {
                                Text(user.nombre ?? "Sin nombre")
                                if selectedUser == user {
                                    Spacer()
                                    Image(systemName: "checkmark.circle.fill").foregroundColor(.blue)
                                }
                            }
                        }
                        .accessibilityIdentifier("userSelection_\(user.nombre ?? "unknown")")
                    }
                }
                .accessibilityIdentifier("newMessageUserList")

                if selectedUser != nil {
                    // Campo de texto para escribir el primer mensaje.
                    TextField("Escribe tu mensaje aquí...", text: $firstMessageText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .accessibilityIdentifier("newMessageTextField")

                    // Botón para enviar el mensaje.
                    Button("Enviar") {
                        startNewConversation()
                    }
                    .disabled(firstMessageText.isEmpty)
                    .padding()
                    .accessibilityIdentifier("sendMessageButton")
                }
            }
            .navigationTitle("Nueva Conversación")
            .navigationBarItems(leading: Button("Cancelar") {
                isShowingNewMessageView = false
            })
        }
    }

    /// Inicia una nueva conversación con el usuario seleccionado.
    private func startNewConversation() {
        guard let selectedUser else { return }

        let context = PersistenceController.shared.context
        let newMessage = Mensaje(context: context)
        newMessage.id = UUID()
        newMessage.contenido = firstMessageText
        newMessage.fecha = Date()
        newMessage.remitente = currentUser
        newMessage.destinatario = selectedUser
        newMessage.leido = false

        do {
            try context.save()
            isShowingNewMessageView = false
        } catch {
            print("Error al iniciar la conversación: \(error.localizedDescription)")
        }
    }
}

/// Fila que representa una conversación en la lista.
struct ConversationRow: View {
    let user: Usuario // Usuario con el que se tiene la conversación.
    let latestMessage: Mensaje // Último mensaje de la conversación.
    let isUnread: Bool // Indica si el último mensaje está sin leer.

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(user.nombre ?? "Sin nombre").font(.headline)
                Text(latestMessage.contenido ?? "Sin mensaje").font(.subheadline)
                    .foregroundColor(isUnread ? .blue : .gray)
            }
            Spacer()
            Text(latestMessage.fecha ?? Date(), formatter: dateFormatter).font(.footnote).foregroundColor(.gray)
        }
        .padding(.vertical, 5)
        .accessibilityIdentifier("conversationRow_\(user.nombre ?? "unknown")")
    }
}

/// Componente de barra de búsqueda personalizado.
struct CustomSearchBar: View {
    @Binding var text: String
    var placeholder: String = "Buscar..."

    var body: some View {
        HStack {
            TextField(placeholder, text: $text)
                .padding(8)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)

                        if !text.isEmpty {
                            Button(action: {
                                text = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                            }
                        }
                    }
                )
        }
        .padding(.horizontal)
        .accessibilityIdentifier("searchBar")
    }
}

