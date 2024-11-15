//
//  CommonView.swift
//  agendaescolaredai
//
//  Created by Juan Antonio Sánchez Carrillo on 16/11/24.
//

import SwiftUI

// MARK: - Componentes Reutilizables

/// Vista individual para cada opción del grid con bordes redondeados, bordes personalizados y efectos visuales.
struct OptionCardView: View {
    let imageName: String // Nombre de la imagen asociada a la opción.
    let title: String // Título que se mostrará debajo de la imagen.
    let action: () -> Void // Closure para manejar la acción al presionar el botón.

    @State private var isPressed: Bool = false // Estado para gestionar la animación de pulsación.

    var body: some View {
        VStack {
            // Imagen de la opción.
            Image(imageName)
                .resizable() // Permite que la imagen sea redimensionable.
                .scaledToFit() // Escala la imagen manteniendo sus proporciones.
                .frame(width: 175, height: 175) // Tamaño fijo de la imagen.
                .cornerRadius(20) // Bordes redondeados para la imagen.
                .overlay(
                    // Borde personalizado alrededor de la imagen.
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(hex: "#7BB2E0"), lineWidth: 5)
                )
                .shadow(color: .gray.opacity(0.5), radius: 10, x: 0, y: 5) // Añade sombra a la imagen.
                .scaleEffect(isPressed ? 0.85 : 1.0) // Escala la imagen durante la pulsación.
                .animation(.easeInOut(duration: 0.2), value: isPressed) // Controla la duración de la animación.
                .padding() // Espaciado alrededor de la imagen.
                .onTapGesture {
                    // Maneja el gesto de pulsación en la imagen.
                    withAnimation {
                        isPressed.toggle() // Cambia el estado para iniciar la animación.
                    }
                    // Retorna al estado inicial y ejecuta la acción tras un breve retardo.
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        isPressed.toggle()
                        action() // Ejecuta la acción asociada.
                    }
                }
                .accessibilityIdentifier("\(title)Icon") // Identificador de accesibilidad para la imagen.

            // Texto del título de la opción.
            Text(title)
                .font(.headline) // Estilo destacado para el texto.
                .foregroundColor(.black) // Color negro para el texto.
                .padding(.top, 5) // Espaciado superior entre la imagen y el texto.
                .accessibilityIdentifier("\(title)Label") // Identificador de accesibilidad para el texto.
        }
        .frame(maxWidth: .infinity) // Asegura que el componente ocupe todo el ancho disponible.
        .accessibilityIdentifier("\(title)Card") // Identificador de accesibilidad para el contenedor.
    }
}

/// Componente de la barra de navegación inferior con soporte para acciones y navegación.
struct BottomTabItem: View {
    let imageName: String // Nombre de la imagen asociada al ícono del tab.
    let label: String // Etiqueta del tab.
    let action: (() -> Void)? // Acción opcional que se ejecutará al presionar el tab.

    var body: some View {
        if let action = action {
            // Si hay una acción definida, envuelve el contenido en un botón.
            Button(action: action) {
                withTransaction(Transaction(animation: nil)) {
                    content // Contenido del tab.
                }
            }
            .accessibilityIdentifier("\(label)Tab") // Identificador de accesibilidad para el tab con acción.
        } else {
            // Si no hay acción, muestra solo el contenido.
            content
                .accessibilityIdentifier("\(label)Tab") // Identificador de accesibilidad para el tab sin acción.
        }
    }

    @ViewBuilder
    private var content: some View {
        VStack(spacing: 4) { // Contenedor con poca separación entre el ícono y el texto.
            // Ícono del tab.
            Image(imageName)
                .resizable() // Permite que el ícono sea redimensionable.
                .scaledToFit() // Escala el ícono manteniendo sus proporciones.
                .frame(width: 80, height: 80) // Tamaño fijo del ícono.

            // Etiqueta del tab.
            Text(label)
                .font(.system(size: 14, weight: .semibold)) // Estilo y tamaño de la fuente.
                .foregroundColor(Color(hex: "#7BB2E0")) // Color personalizado en azul.
        }
    }
}

// Extensión para crear un color desde un código hexadecimal.
extension Color {
    /// Inicializa un color basado en un código hexadecimal.
    /// - Parameter hex: Cadena de texto representando el código hexadecimal del color.
    init(hex: String) {
        // Elimina el prefijo "#" si está presente en el código.
        let hexString = hex.hasPrefix("#") ? String(hex.dropFirst()) : hex
        let scanner = Scanner(string: hexString) // Scanner para convertir el texto a un valor numérico.
        var rgbValue: UInt64 = 0 // Almacena el valor RGB del color.
        scanner.scanHexInt64(&rgbValue) // Convierte el texto hexadecimal a un valor entero.

        // Extrae los componentes rojo, verde y azul.
        let red = Double((rgbValue >> 16) & 0xFF) / 255.0
        let green = Double((rgbValue >> 8) & 0xFF) / 255.0
        let blue = Double(rgbValue & 0xFF) / 255.0

        // Inicializa el color utilizando los componentes RGB.
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: 1.0)
    }
}

/// Botón de opción reducido, específicamente para la vista de administrador.
struct SmallOptionCardView: View {
    let imageName: String // Nombre de la imagen asociada a la opción.
    let title: String // Título que se mostrará debajo de la imagen.
    let action: () -> Void // Closure para manejar la acción al presionar el botón.

    @State private var isPressed: Bool = false // Estado para gestionar la animación de pulsación.

    var body: some View {
        VStack {
            // Imagen de la opción.
            Image(imageName)
                .resizable() // Permite que la imagen sea redimensionable.
                .scaledToFit() // Escala la imagen manteniendo sus proporciones.
                .frame(width: 120, height: 120) // Tamaño fijo de la imagen.
                .cornerRadius(20) // Bordes redondeados para la imagen.
                .overlay(
                    // Borde personalizado alrededor de la imagen.
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(hex: "#7BB2E0"), lineWidth: 5)
                )
                .shadow(color: .gray.opacity(0.5), radius: 10, x: 0, y: 5) // Añade sombra a la imagen.
                .scaleEffect(isPressed ? 0.85 : 1.0) // Escala la imagen durante la pulsación.
                .animation(.easeInOut(duration: 0.2), value: isPressed) // Controla la duración de la animación.
                .padding() // Espaciado alrededor de la imagen.
                .onTapGesture {
                    // Maneja el gesto de pulsación en la imagen.
                    withAnimation {
                        isPressed.toggle() // Cambia el estado para iniciar la animación.
                    }
                    // Retorna al estado inicial y ejecuta la acción tras un breve retardo.
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        isPressed.toggle()
                        action() // Ejecuta la acción asociada.
                    }
                }
                .accessibilityIdentifier("\(title)SmallIcon") // Identificador de accesibilidad para la imagen.

            // Texto del título de la opción.
            Text(title)
                .font(.headline) // Estilo destacado para el texto.
                .foregroundColor(.black) // Color negro para el texto.
                .padding(.top, 2) // Espaciado superior entre la imagen y el texto.
                .accessibilityIdentifier("\(title)SmallLabel") // Identificador de accesibilidad para el texto.
        }
        .frame(maxWidth: .infinity) // Asegura que el componente ocupe todo el ancho disponible.
        .accessibilityIdentifier("\(title)SmallCard") // Identificador de accesibilidad para el contenedor.
    }
}

/// Vista para mostrar una fila de aula con su información básica.
struct AulaRowView: View {
    let aula: Aula // Aula que se representará en esta fila.

    var body: some View {
        // Diseño horizontal para la fila del aula.
        HStack {
            // Imagen asociada al aula.
            if let imagenNombre = aula.imagen, let uiImage = UIImage(named: imagenNombre) {
                // Si existe una imagen válida asociada al aula.
                Image(uiImage: uiImage)
                    .resizable() // Permite redimensionar la imagen.
                    .scaledToFill() // Escala la imagen para llenar el espacio.
                    .frame(width: 120, height: 120) // Define el tamaño de la imagen.
                    .cornerRadius(12) // Bordes redondeados.
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(hex: "#7BB2E0"), lineWidth: 5) // Añade un borde con color personalizado.
                    )
                    .shadow(radius: 5) // Añade una sombra a la imagen.
                    .accessibilityIdentifier("aulaImage")
            } else {
                // Imagen predeterminada si no hay una imagen asociada.
                Image("placeHolder")
                    .resizable() // Permite redimensionar la imagen.
                    .scaledToFill() // Escala la imagen para que se ajuste proporcionalmente.
                    .frame(width: 120, height: 120) // Define el tamaño de la imagen.
                    .cornerRadius(12) // Bordes redondeados.
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(hex: "#7BB2E0"), lineWidth: 5) // Añade un borde con color personalizado.
                    )
                    .shadow(radius: 5) // Añade una sombra a la imagen.
                    .accessibilityIdentifier("aulaDefaultImage")
            }

            // Contenedor de texto con la información del aula.
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    // Nombre del aula.
                    Text(aula.nombre ?? "Sin Nombre")
                        .font(.headline)
                        .accessibilityIdentifier("aulaName")
                    Spacer()
                }

                // Centro asociado al aula.
                if let centroNombre = aula.centro?.nombre {
                    Text("Centro: \(centroNombre)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .accessibilityIdentifier("aulaCentro")
                } else {
                    Text("Centro: Sin Centro")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .accessibilityIdentifier("aulaCentroPlaceholder")
                }

                // Rango de edad del aula.
                Text("Rango de edad: \(aula.edadMinima)-\(aula.edadMaxima) años")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .accessibilityIdentifier("aulaAgeRange")

                // Total de alumnos específicos del aula y su centro.
                Text("Alumnos: \(countAlumnos(for: aula))")
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .accessibilityIdentifier("aulaStudentCount")
            }
            .padding(.vertical, 5) // Espaciado vertical entre las filas.
        }
        .padding(.vertical, 5) // Espaciado interno en cada fila.
        .accessibilityIdentifier("aulaRow")
    }

    /// Método para contar los alumnos asociados al aula y su centro.
    private func countAlumnos(for aula: Aula) -> Int {
        guard let alumnos = aula.alumnos as? Set<Alumno> else { return 0 }
        return alumnos.filter { $0.centro == aula.centro }.count
    }
}

/// Vista para mostrar la información básica de un usuario en una fila.
struct UserRowView: View {
    let user: Usuario // Usuario que se mostrará.
    let onTap: () -> Void // Acción al seleccionar la fila.

    var body: some View {
        HStack {
            // Imagen predeterminada para todos los usuarios.
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .foregroundColor(.gray) // Color predeterminado para el icono.
                .accessibilityIdentifier("defaultUserIcon")

            VStack(alignment: .leading) {
                // Nombre del usuario.
                Text(user.nombre ?? "Sin Nombre")
                    .font(.headline)
                    .accessibilityIdentifier("userName_\(user.nombre ?? "unknown")")

                // Rol del usuario.
                Text(user.rol ?? "Sin Rol")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .accessibilityIdentifier("userRole_\(user.rol ?? "unknown")")
            }
            Spacer()
        }
        .padding(.vertical, 5)
        .contentShape(Rectangle()) // Permite seleccionar toda la fila.
        .onTapGesture {
            onTap() // Acción al tocar la fila.
        }
        .accessibilityIdentifier("userRow_\(user.nombre ?? "unknown")")
    }
}

/// Vista para mostrar la información básica de un alumno en una fila.
struct StudentRowView: View {
    let student: Alumno // Alumno que se mostrará.
    let onTap: () -> Void // Acción al seleccionar la fila.

    var body: some View {
        HStack {
            // Imagen del alumno o ícono predeterminado.
            if let imageName = student.imagen, let uiImage = UIImage(named: imageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .accessibilityIdentifier("studentImage_\(student.nombre ?? "unknown")")
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.gray)
                    .accessibilityIdentifier("defaultStudentIcon")
            }

            VStack(alignment: .leading) {
                // Nombre del alumno.
                Text(student.nombre ?? "Sin Nombre")
                    .font(.headline)
                    .accessibilityIdentifier("studentName_\(student.nombre ?? "unknown")")

                // Curso del alumno.
                Text(student.aula?.nombre ?? "Sin Aula")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .accessibilityIdentifier("studentAula_\(student.aula?.curso ?? "unknown")")
            }
            Spacer()
        }
        .padding(.vertical, 5)
        .contentShape(Rectangle()) // Permite seleccionar toda la fila.
        .onTapGesture {
            onTap() // Acción al tocar la fila.
        }
        .accessibilityIdentifier("studentRow_\(student.nombre ?? "unknown")")
    }
}

// MARK: - Extensiones y Utilidades Globales

/// Calcula la edad a partir de una fecha.
/// - Parameter fecha: Fecha de nacimiento.
/// - Returns: Edad en años como un número entero.
func calcularEdad(fecha: Date) -> Int {
    let calendar = Calendar.current
    let ageComponents = calendar.dateComponents([.year], from: fecha, to: Date())
    return ageComponents.year ?? 0
}

/// Formateador de fechas para mostrar en formato "dd/MM/yyyy".
let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "es_ES") // Configura el idioma español.
    formatter.dateFormat = "dd/MM/yyyy" // Define el formato de la fecha.
    return formatter
}()

/// Carga una imagen desde el sistema de archivos o los assets.
/// - Parameter fileName: Nombre del archivo.
/// - Returns: `UIImage` si se encuentra, o `nil` si no existe.
func loadImage(named fileName: String) -> UIImage? {
    let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent(fileName)
    if FileManager.default.fileExists(atPath: url.path) {
        return UIImage(contentsOfFile: url.path)
    }
    return UIImage(named: fileName)
}

/// Vista reutilizable para mostrar un mensaje flotante tipo Toast.
struct ToastView: View {
    let message: String // Texto que se mostrará en el mensaje.
    let isError: Bool // Indica si el mensaje es de error (rojo) o éxito (verde).

    var body: some View {
        Text(message)
            .font(.subheadline)
            .padding()
            .frame(maxWidth: .infinity)
            .background(isError ? Color.red.opacity(0.9) : Color.green.opacity(0.9)) // Fondo rojo o verde según el estado.
            .foregroundColor(.white) // Texto en blanco.
            .cornerRadius(8) // Bordes redondeados.
            .padding() // Espaciado alrededor del contenedor.
    }
}

/// Función para mostrar un Toast en una vista.
/// - Parameters:
///   - message: Texto del mensaje.
///   - isError: Si es un error (rojo) o éxito (verde).
///   - state: Binding para controlar su visibilidad.
///   - duration: Duración en segundos antes de ocultar el Toast.
func showToast(message: String, isError: Bool, state: Binding<Bool>, duration: Double = 3.0) {
    state.wrappedValue = true
    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
        state.wrappedValue = false
    }
}
