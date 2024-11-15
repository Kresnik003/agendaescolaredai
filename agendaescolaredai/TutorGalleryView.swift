//
//  TutorGalleryView.swift
//  agendaescolaredai
//
//  Created by Juan Antonio Sánchez Carrillo on 23/11/24.
//

import SwiftUI
import CoreData

/// Vista diseñada para que los tutores puedan visualizar las fotos asociadas en una galería.
/// Proporciona funcionalidades para:
/// - Explorar imágenes almacenadas en Core Data.
/// - Ampliar imágenes seleccionadas.
/// - Descargar imágenes al dispositivo.
struct TutorGalleryView: View {
    /// `FetchRequest` para obtener fotos desde Core Data.
    /// Las fotos se ordenan en orden descendente según la fecha.
    @FetchRequest(
        entity: Foto.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Foto.fecha, ascending: false)]
    ) var fotos: FetchedResults<Foto>

    /// Imagen seleccionada para ampliación y descarga.
    @State private var selectedImage: UIImage?

    /// Controla si se muestra la vista de zoom para la imagen seleccionada.
    @State private var showImageZoom = false

    /// Controla si se muestra una alerta tras descargar una imagen.
    @State private var showDownloadAlert = false

    /// Vista principal de navegación con una cuadrícula de imágenes.
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ForEach(fotos, id: \.id) { foto in
                        // Muestra cada foto almacenada en Core Data.
                        if let imageData = foto.imagen, let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 170, height: 170) // Tamaño estándar para las imágenes en la cuadrícula.
                                .clipShape(RoundedRectangle(cornerRadius: 12)) // Forma redondeada.
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(hex: "#7BB2E0"), lineWidth: 2) // Borde decorativo azul.
                                )
                                .shadow(radius: 3) // Sombra ligera para destacar las imágenes.
                                .onTapGesture {
                                    // Activa el zoom para la imagen seleccionada.
                                    selectedImage = uiImage
                                    showImageZoom = true
                                }
                                .accessibilityIdentifier("tutorGalleryImage_\(foto.id?.uuidString ?? "unknown")") // Identificador único para pruebas.
                        } else {
                            // Imagen de marcador de posición si no hay datos válidos.
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 170, height: 170)
                                .foregroundColor(.gray)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .accessibilityIdentifier("tutorGalleryPlaceholder")
                        }
                    }
                }
                .padding() // Margen general alrededor de la cuadrícula.
            }
            .navigationTitle("Galería de Fotos") // Título principal de la vista.
            .sheet(isPresented: Binding<Bool>(
                get: { selectedImage != nil }, // Muestra la hoja si hay una imagen seleccionada.
                set: { if !$0 { selectedImage = nil } } // Reinicia el estado al cerrarla.
            )) {
                if let selectedImage = selectedImage {
                    TutorImageZoomView(image: selectedImage, showDownloadAlert: $showDownloadAlert)
                }
            }
            .alert(isPresented: $showDownloadAlert) {
                // Alerta de confirmación tras la descarga de una imagen.
                Alert(
                    title: Text("Descarga Completada"),
                    message: Text("La imagen se ha guardado en tu galería."),
                    dismissButton: .default(Text("Aceptar"))
                )
            }
        }
    }
}

/// Vista diseñada para ampliar y descargar imágenes seleccionadas desde la galería del tutor.
struct TutorImageZoomView: View {
    /// Imagen seleccionada.
    let image: UIImage

    /// Controla si se muestra la alerta tras la descarga.
    @Binding var showDownloadAlert: Bool

    /// Escala acumulada del zoom tras cada gesto.
    @State private var accumulatedScale: CGFloat = 1.0

    /// Escala temporal durante el gesto de zoom actual.
    @State private var currentScale: CGFloat = 1.0

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all) // Fondo negro que cubre toda la pantalla.

            VStack {
                // Imagen ampliada con capacidad de zoom.
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(accumulatedScale * currentScale) // Aplica la escala acumulada y temporal.
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                currentScale = value // Actualiza la escala temporal durante el gesto.
                            }
                            .onEnded { value in
                                accumulatedScale *= value // Acumula la escala final tras el gesto.
                                currentScale = 1.0 // Reinicia la escala temporal.
                            }
                    )
                    .accessibilityLabel("Imagen ampliada")
                    .accessibilityHint("Usa el gesto de pellizco para hacer zoom")

                Spacer()

                // Botón para descargar la imagen.
                Button(action: saveImageToGallery) {
                    HStack {
                        Image(systemName: "square.and.arrow.down") // Ícono de descarga.
                        Text("Descargar Imagen") // Etiqueta del botón.
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                .padding()
                .accessibilityIdentifier("downloadButton")
            }
        }
    }

    /// Guarda la imagen en la galería del dispositivo.
    private func saveImageToGallery() {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil) // Realiza la descarga.
        showDownloadAlert = true // Activa la alerta tras la descarga.
    }
}
