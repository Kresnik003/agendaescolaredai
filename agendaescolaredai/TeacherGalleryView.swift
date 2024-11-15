//
//  TeacherGalleryView.swift
//  agendaescolaredai
//
//  Created by Juan Antonio Sánchez Carrillo on 23/11/24.
//

import SwiftUI
import CoreData
import PhotosUI

/// Vista diseñada para que los profesores puedan gestionar y visualizar su galería de fotos.
/// Esta vista integra las funcionalidades de:
/// - Subir nuevas imágenes desde el dispositivo.
/// - Mostrar imágenes almacenadas en Core Data.
/// - Permitir el zoom de imágenes seleccionadas.
/// - Descargar imágenes al almacenamiento local del dispositivo.
struct TeacherGalleryView: View {
    /// `FetchRequest` para acceder a las fotos almacenadas en Core Data.
    /// Las fotos se ordenan en orden descendente por fecha, mostrando las más recientes primero.
    @FetchRequest(
        entity: Foto.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Foto.fecha, ascending: false)]
    ) var fotos: FetchedResults<Foto>

    /// Imagen seleccionada por el usuario para ampliación o descarga.
    @State private var selectedImage: UIImage?

    /// Controla si la vista de zoom se muestra para una imagen seleccionada.
    @State private var showImageZoom = false

    /// Controla la visualización de una alerta tras descargar una imagen.
    @State private var showDownloadAlert = false

    /// Controla si se muestra el selector de fotos para subir una nueva imagen.
    @State private var showPhotoPicker = false

    /// Contexto de Core Data utilizado para guardar nuevas fotos subidas.
    @Environment(\.managedObjectContext) private var context

    /// Vista principal de la galería.
    /// Incluye un botón para subir imágenes y un contenedor en cuadrícula para visualizar las fotos existentes.
    var body: some View {
        NavigationView {
            VStack {
                // Botón para subir nuevas imágenes desde el dispositivo.
                Button(action: {
                    // Abre el selector de fotos.
                    showPhotoPicker = true
                }) {
                    HStack {
                        Image(systemName: "plus") // Icono de "añadir".
                        Text("Subir Imagen") // Etiqueta del botón.
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(Color(hex: "#7BB2E0")) // Color de fondo azul propio.
                    .cornerRadius(10) // Bordes redondeados.
                }
                .sheet(isPresented: $showPhotoPicker) {
                    // Muestra el selector de fotos.
                    ImagePicker { selectedImage in
                        // Llama al método para guardar la imagen seleccionada en Core Data.
                        saveImageToCoreData(selectedImage)
                    }
                }
                .accessibilityIdentifier("uploadImageButton") // Identificador para pruebas de accesibilidad.

                // Cuadrícula de fotos almacenadas.
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach(fotos, id: \.id) { foto in
                            // Intenta cargar la imagen de los datos almacenados en Core Data.
                            if let imageData = foto.imagen, let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage) // Representación visual de la imagen.
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 170, height: 170) // Dimensiones de la imagen.
                                    .clipShape(RoundedRectangle(cornerRadius: 12)) // Forma con bordes redondeados.
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color(hex: "#7BB2E0"), lineWidth: 2) // Borde decorativo azul.
                                    )
                                    .shadow(radius: 3) // Sombra ligera.
                                    .onTapGesture {
                                        // Al tocar, selecciona la imagen para ampliación.
                                        selectedImage = uiImage
                                        showImageZoom = true
                                    }
                                    .accessibilityIdentifier("teacherGalleryImage_\(foto.id?.uuidString ?? "unknown")") // Identificador único para pruebas.
                            }
                        }
                    }
                    .padding() // Margen alrededor de la cuadrícula.
                }
            }
            .navigationTitle("Galería de Fotos") // Título de la vista.
            .sheet(isPresented: Binding<Bool>(
                get: { selectedImage != nil }, // Muestra la hoja si hay una imagen seleccionada.
                set: { if !$0 { selectedImage = nil } } // Reinicia el estado al cerrarla.
            )) {
                if let selectedImage = selectedImage {
                    // Muestra la vista para ampliar o descargar la imagen seleccionada.
                    TeacherImageZoomView(image: selectedImage, showDownloadAlert: $showDownloadAlert)
                }
            }
            .alert(isPresented: $showDownloadAlert) {
                // Alerta que confirma la descarga de la imagen.
                Alert(
                    title: Text("Descarga Completada"),
                    message: Text("La imagen se ha guardado en tu galería."),
                    dismissButton: .default(Text("Aceptar"))
                )
            }
        }
    }

    /// Método que guarda una imagen seleccionada en Core Data.
    /// - Parameter image: Imagen seleccionada por el usuario.
    private func saveImageToCoreData(_ image: UIImage) {
        // Convierte la imagen en datos JPEG con compresión.
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }

        // Crea una nueva instancia de `Foto` y la configura.
        let newPhoto = Foto(context: context)
        newPhoto.id = UUID() // Genera un identificador único.
        newPhoto.fecha = Date() // Registra la fecha actual.
        newPhoto.imagen = imageData // Asocia los datos de la imagen.

        // Intenta guardar los cambios en Core Data.
        do {
            try context.save()
        } catch {
            print("Error al guardar la imagen: \(error.localizedDescription)")
        }
    }
}

/// Vista para ampliar una imagen seleccionada y permitir su descarga.
struct TeacherImageZoomView: View {
    /// Imagen que se está visualizando.
    let image: UIImage

    /// Controla la visualización de la alerta tras la descarga.
    @Binding var showDownloadAlert: Bool

    /// Escala acumulada del zoom.
    @State private var accumulatedScale: CGFloat = 1.0

    /// Escala temporal mientras el gesto de zoom está activo.
    @State private var currentScale: CGFloat = 1.0

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all) // Fondo negro para resaltar la imagen.

            VStack {
                // Imagen ampliada con funcionalidad de zoom.
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(accumulatedScale * currentScale) // Aplica la escala acumulada y temporal.
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                currentScale = value // Actualiza la escala mientras el gesto está activo.
                            }
                            .onEnded { value in
                                accumulatedScale *= value // Acumula la escala final tras el gesto.
                                currentScale = 1.0 // Reinicia la escala temporal.
                            }
                    )
                Spacer()

                // Botón para descargar la imagen al dispositivo.
                Button(action: saveImageToGallery) {
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                        Text("Descargar Imagen")
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                .accessibilityIdentifier("downloadButton")
            }
        }
    }

    /// Método para guardar la imagen ampliada en la galería del dispositivo.
    private func saveImageToGallery() {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil) // Realiza la descarga.
        showDownloadAlert = true // Activa la alerta de confirmación.
    }
}

/// Componente que permite seleccionar una imagen desde el dispositivo.
struct ImagePicker: UIViewControllerRepresentable {
    /// Closure que devuelve la imagen seleccionada.
    var completion: (UIImage) -> Void

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images // Limita a imágenes.
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(completion: completion)
    }

    /// Coordinador que gestiona los resultados del selector de imágenes.
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var completion: (UIImage) -> Void

        init(completion: @escaping (UIImage) -> Void) {
            self.completion = completion
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else { return }

            provider.loadObject(ofClass: UIImage.self) { (image, error) in
                if let uiImage = image as? UIImage {
                    DispatchQueue.main.async {
                        self.completion(uiImage)
                    }
                }
            }
        }
    }
}
