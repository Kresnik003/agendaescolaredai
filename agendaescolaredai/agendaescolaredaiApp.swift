//
//  agendaescolaredaiApp.swift
//  agendaescolaredai
//

import SwiftUI
import CoreData
import Combine // Import necesario para AnyCancellable.

/// Punto de entrada principal de la aplicación.
/// Define la configuración inicial y la estructura básica para la ejecución de la aplicación.
@main
struct agendaescolaredaiApp: App {
    /// Instancia compartida del controlador de persistencia para gestionar Core Data.
    /// Se utiliza para acceder y manipular los datos almacenados localmente.
    let persistenceController = PersistenceController.shared

    /// Variable para controlar si la base de datos debe ser reseteada.
    /// Cambiar este valor a `true` permite eliminar todos los datos existentes
    /// y repoblar la base de datos con datos iniciales.
    private let resetDatabase = false // Cambia a `true` para forzar el reseteo de la base de datos.

    /// Cuerpo principal de la aplicación.
    /// Define la escena principal que se mostrará al usuario.
    var body: some Scene {
        WindowGroup {
            ContentView()
                /// Permite que las vistas accedan al contexto de Core Data.
                /// Proporciona el contexto de vista gestionado como parte del entorno.
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onAppear {
                    /// Al aparecer la vista principal, determina si se debe resetear o verificar la base de datos.
                    if resetDatabase {
                        print("Reseteando la base de datos...")
                        deleteAllData()
                        populateDatabase()
                    } else {
                        checkAndPopulateDatabase()
                    }
                }
        }
    }

    /// Verifica si la base de datos está vacía y la puebla si es necesario.
    /// Este método realiza una consulta al modelo `Centro` para determinar si existen datos almacenados.
    private func checkAndPopulateDatabase() {
        // Obtiene el contexto actual de Core Data.
        let context = persistenceController.container.viewContext

        // Realiza una consulta para verificar si hay datos en la tabla `Centro`.
        let fetchRequest: NSFetchRequest<Centro> = Centro.fetchRequest()
        do {
            let count = try context.count(for: fetchRequest)
            if count == 0 {
                // Si no hay datos, inicializa la base de datos con datos predeterminados.
                print("La base de datos está vacía. Poblando datos iniciales...")
                populateDatabase()
            } else {
                // Si la base de datos ya contiene datos, no realiza ningún cambio.
                print("La base de datos ya contiene datos. No se puebla nuevamente.")
            }
        } catch {
            // Captura y maneja cualquier error durante la verificación de la base de datos.
            print("Error al verificar la base de datos: \(error.localizedDescription)")
        }
    }
}
