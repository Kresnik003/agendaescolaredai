//
//  ChatView.swift
//  agendaescolaredai
//
//  Created by Juan Antonio Sánchez Carrillo on 18/11/24.
//

import SwiftUI
import CoreData

/// Vista para mostrar una conversación al estilo WhatsApp.
struct ChatView: View {
    // El usuario actual que está logueado en la aplicación. Se utiliza para determinar qué mensajes son enviados por el usuario actual.
    let currentUser: Usuario

    // El usuario con el que el usuario actual está conversando. Se utiliza para mostrar información y mensajes relevantes a esta conversación.
    let otherUser: Usuario

    // FetchRequest que recupera los mensajes almacenados en Core Data entre el usuario actual y el otro usuario.
    @FetchRequest private var mensajes: FetchedResults<Mensaje>

    // Variable de estado para almacenar temporalmente el texto del nuevo mensaje que el usuario está escribiendo.
    @State private var newMessageText: String = ""

    /// Inicializador que configura el FetchRequest para recuperar mensajes relevantes de Core Data.
    /// - Parameters:
    ///   - currentUser: El usuario logueado actualmente.
    ///   - otherUser: El usuario con el que se está conversando.
    init(currentUser: Usuario, otherUser: Usuario) {
        self.currentUser = currentUser
        self.otherUser = otherUser

        // Define un predicado para recuperar los mensajes enviados desde el usuario actual al otro usuario.
        let predicateSender = NSPredicate(format: "remitente == %@ AND destinatario == %@", currentUser, otherUser)

        // Define un predicado para recuperar los mensajes enviados desde el otro usuario al usuario actual.
        let predicateReceiver = NSPredicate(format: "remitente == %@ AND destinatario == %@", otherUser, currentUser)

        // Combina ambos predicados utilizando OR para incluir mensajes enviados y recibidos entre los dos usuarios.
        let compoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicateSender, predicateReceiver])

        // Configura el FetchRequest con los predicados y ordena los resultados por fecha en orden ascendente.
        _mensajes = FetchRequest(
            entity: Mensaje.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Mensaje.fecha, ascending: true)],
            predicate: compoundPredicate
        )
    }

    var body: some View {
        VStack {
            // ScrollView para mostrar los mensajes en la conversación.
            ScrollViewReader { scrollView in
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        // Itera sobre los mensajes y los muestra en burbujas de chat.
                        ForEach(mensajes, id: \.id) { mensaje in
                            ChatBubbleView(
                                message: mensaje,
                                isCurrentUser: mensaje.remitente == currentUser
                            )
                            .accessibilityIdentifier("chatMessage_\(mensaje.id?.uuidString ?? "unknown")")
                        }
                    }
                    .padding() // Agrega espaciado interno alrededor de las burbujas de mensaje.
                    .onAppear {
                        // Cuando aparece la vista, desplaza automáticamente al último mensaje.
                        scrollView.scrollTo(mensajes.last?.id, anchor: .bottom)
                    }
                    .onChange(of: mensajes.count) { newValue, oldValue in
                        // Si se detecta un cambio en el número de mensajes, desplaza al último mensaje con animación.
                        if newValue > oldValue {
                            withAnimation {
                                scrollView.scrollTo(mensajes.last?.id, anchor: .bottom)
                            }
                        }
                    }
                }
                .accessibilityIdentifier("messageScrollView")
            }

            // Barra para escribir y enviar mensajes.
            HStack {
                // Campo de texto donde el usuario escribe un nuevo mensaje.
                TextField("Escribe un mensaje", text: $newMessageText)
                    .padding() // Espaciado interno para el campo de texto.
                    .background(Color(.systemGray6)) // Fondo de color gris claro.
                    .cornerRadius(10) // Bordes redondeados para el campo de texto.
                    .accessibilityIdentifier("messageInputField")

                // Botón para enviar el mensaje.
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill") // Icono de avión de papel para representar el envío.
                        .foregroundColor(.blue) // Color azul para el icono.
                        .font(.system(size: 24)) // Tamaño del icono.
                        .accessibilityIdentifier("sendMessageButton")
                }
            }
            .padding() // Agrega espaciado alrededor de la barra de entrada.
        }
        .navigationTitle(otherUser.nombre ?? "Chat") // Título de la vista basado en el nombre del otro usuario.
        .navigationBarTitleDisplayMode(.inline) // Muestra el título alineado con la barra de navegación.
        .accessibilityIdentifier("chatView")
    }

    /// Envía un mensaje y lo guarda en Core Data.
    private func sendMessage() {
        // Verifica que el mensaje no esté vacío antes de enviarlo.
        guard !newMessageText.isEmpty else { return }

        // Obtiene el contexto de Core Data.
        let context = PersistenceController.shared.context

        // Crea un nuevo objeto de tipo `Mensaje`.
        let mensaje = Mensaje(context: context)
        mensaje.id = UUID() // Asigna un identificador único.
        mensaje.contenido = newMessageText // Asigna el contenido del mensaje.
        mensaje.fecha = Date() // Asigna la fecha actual como fecha del mensaje.
        mensaje.remitente = currentUser // Asigna el usuario actual como remitente.
        mensaje.destinatario = otherUser // Asigna el otro usuario como destinatario.

        // Intenta guardar el mensaje en Core Data.
        do {
            try context.save() // Guarda los cambios en Core Data.
            newMessageText = "" // Limpia el campo de texto después de enviar el mensaje.
        } catch {
            // Si ocurre un error, muestra un mensaje de error en la consola.
            print("Error al enviar el mensaje: \(error.localizedDescription)")
        }
    }
}

/// Vista para representar una burbuja de chat.
struct ChatBubbleView: View {
    let message: Mensaje // Mensaje que se mostrará en la burbuja.
    let isCurrentUser: Bool // Indica si el mensaje fue enviado por el usuario actual.

    var body: some View {
        HStack {
            // Si el mensaje es del usuario actual, agrega un espacio al inicio.
            if isCurrentUser { Spacer() }

            // Contenido del mensaje en una burbuja.
            Text(message.contenido ?? "") // Muestra el contenido del mensaje.
                .padding() // Espaciado interno de la burbuja.
                .foregroundColor(.white) // Texto en color blanco.
                .background(isCurrentUser ? Color.blue : Color.gray) // Fondo azul para el usuario actual y gris para el otro.
                .cornerRadius(16) // Bordes redondeados para la burbuja.
                .frame(maxWidth: .infinity, alignment: isCurrentUser ? .trailing : .leading) // Alinea a la derecha o izquierda.
                .accessibilityIdentifier(isCurrentUser ? "sentMessageBubble" : "receivedMessageBubble")

            // Si el mensaje no es del usuario actual, agrega un espacio al final.
            if !isCurrentUser { Spacer() }
        }
    }
}
