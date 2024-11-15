//
//  LoginView.swift
//  agendaescolaredai
//
//  Created by Juan Antonio Sánchez Carrillo on 16/11/24.
//

import SwiftUI
import CoreData

/// Vista de inicio de sesión para la aplicación.
/// Permite a los usuarios autenticar sus credenciales y acceder a las funcionalidades de la aplicación.
struct LoginView: View {
    // Estado que controla si el usuario está logueado.
    @Binding var isUserLoggedIn: Bool
    // Referencia al usuario actual logueado.
    @Binding var currentUser: Usuario?

    // Campos de entrada para capturar las credenciales del usuario.
    @State private var email = "" // Correo electrónico ingresado por el usuario.
    @State private var contrasena = "" // Contraseña ingresada por el usuario.

    // Control de alertas para mostrar errores.
    @State private var showAlert = false // Indica si se debe mostrar la alerta.
    @State private var alertMessage = "" // Mensaje que se mostrará en la alerta.

    // URLs de redes sociales para redirección.
    private let facebookURL = URL(string: "https://www.facebook.com/people/EDAI-escuelas-infantiles/100054556833964/")!
    private let instagramURL = URL(string: "https://www.instagram.com/edai_escuelas/?hl=es")!
    private let webURL = URL(string: "https://www.escolaedai.es")!

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer()

                // Imagen del logo más grande para mayor protagonismo.
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 400, height: 400) // Tamaño del logo incrementado.
                    .background(Color.white) // Fondo blanco para resaltar el logo.
                    .cornerRadius(12) // Bordes redondeados.
                    .shadow(color: .gray.opacity(0.5), radius: 5, x: 0, y: 3) // Sombra ligera.
                    .padding(.top, 20) // Espaciado superior.
                    .accessibilityIdentifier("appLogo")

                // Título de la vista.
                Text("Inicio de Sesión")
                    .font(.largeTitle) // Fuente grande.
                    .bold() // Negrita para destacar.
                    .foregroundColor(Color.black) // Texto negro.
                    .accessibilityIdentifier("loginTitle")

                Spacer()

                // Campos de entrada para email y contraseña.
                Group {
                    // Campo de correo electrónico.
                    TextField("Correo Electrónico", text: $email)
                        .keyboardType(.emailAddress) // Teclado optimizado para correos.
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .padding()
                        .background(Color.white) // Fondo blanco para diferenciarlo.
                        .cornerRadius(8)
                        .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2) // Sombra para destacar.
                        .accessibilityIdentifier("emailTextField")

                    // Campo de contraseña.
                    SecureField("Contraseña", text: $contrasena)
                        .padding()
                        .background(Color.white) // Fondo blanco para diferenciarlo.
                        .cornerRadius(8)
                        .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2) // Sombra para destacar.
                        .accessibilityIdentifier("passwordSecureField")
                }
                .padding(.horizontal)

                // Botón para iniciar sesión.
                Button(action: authenticateUser) {
                    Text("Iniciar Sesión")
                        .foregroundColor(.white) // Texto blanco.
                        .padding() // Espaciado interno.
                        .frame(maxWidth: .infinity) // Ocupa todo el ancho disponible.
                        .background(Color(hex: "#7BB2E0")) // Fondo azul claro.
                        .cornerRadius(8) // Bordes redondeados.
                        .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 3) // Sombra para destacar.
                }
                .padding(.horizontal)
                .accessibilityIdentifier("loginButton")

                Spacer()

                // Iconos de redes sociales.
                HStack(spacing: 20) {
                    SocialMediaIcon(imageName: "facebookIcon", url: facebookURL)
                        .accessibilityIdentifier("facebookIcon")
                    SocialMediaIcon(imageName: "instagramIcon", url: instagramURL)
                        .accessibilityIdentifier("instagramIcon")
                    SocialMediaIcon(imageName: "AppLogo", url: webURL)
                        .accessibilityIdentifier("webIcon")
                }
                .padding(.bottom, 20)
                .onTapGesture {
                    hideKeyboard() // Oculta el teclado al tocar cualquier parte de la vista.
                }
            }
            .padding()
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .scrollDismissesKeyboard(.interactively)
    }

    /// Función para autenticar al usuario.
    private func authenticateUser() {
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<Usuario> = Usuario.fetchRequest()

        // Define el predicado para buscar las credenciales en Core Data.
        fetchRequest.predicate = NSPredicate(format: "email == %@ AND contrasena == %@", email, contrasena)

        do {
            // Ejecuta la consulta.
            let results = try context.fetch(fetchRequest)
            if let user = results.first {
                currentUser = user
                isUserLoggedIn = true
            } else {
                alertMessage = "Correo o contraseña incorrectos. Inténtelo de nuevo."
                showAlert = true
            }
        } catch {
            alertMessage = "Hubo un error al intentar iniciar sesión: \(error.localizedDescription)"
            showAlert = true
        }
    }
}

/// Vista para mostrar un icono de red social que abre un enlace al tocarlo.
struct SocialMediaIcon: View {
    let imageName: String // Nombre del icono.
    let url: URL // URL a la que redirige el icono.

    var body: some View {
        Button(action: {
            UIApplication.shared.open(url)
        }) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50) // Tamaño del icono.
                .cornerRadius(10) // Bordes redondeados.
                .shadow(color: .gray.opacity(0.4), radius: 3, x: 0, y: 2) // Sombra ligera.
        }
    }
}

// Extensión para ocultar el teclado.
extension View {
    /// Oculta el teclado al tocar cualquier parte de la vista.
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
