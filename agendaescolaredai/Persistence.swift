//
//  Persistence.swift
//  agendaescolaredai
//
//  Created by Juan Antonio Sánchez Carrillo on 15/11/24.
//

import CoreData

/// Controlador persistente de Core Data para administrar la base de datos de la aplicación.
/// Este controlador centraliza la configuración y acceso al contenedor persistente de Core Data,
/// facilitando la interacción con la base de datos en toda la aplicación.
struct PersistenceController {
    /// Singleton para el acceso compartido al controlador persistente.
    /// Permite que todas las partes de la aplicación utilicen la misma instancia,
    /// asegurando un manejo centralizado de la base de datos.
    static let shared = PersistenceController()

    /// Contenedor persistente de Core Data que maneja la base de datos.
    /// Es el núcleo del sistema de persistencia, responsable de cargar y manejar los datos almacenados.
    let container: NSPersistentContainer

    /// Inicialización del contenedor persistente con el modelo de Core Data.
    /// Configura y carga los almacenes persistentes, deteniendo la ejecución si ocurre algún error crítico.
    init() {
        // Inicializa el contenedor con el modelo de datos "agendaescolaredai".
        container = NSPersistentContainer(name: "agendaescolaredai")
        
        // Carga los almacenes persistentes asociados al contenedor.
        container.loadPersistentStores { description, error in
            if let error = error {
                // Detiene la ejecución y registra un error crítico si no se puede cargar el almacén.
                fatalError("Error al cargar la base de datos: \(error.localizedDescription)")
            }
        }
        // Configuraciones adicionales del contenedor (e.g., políticas de fusión) pueden añadirse aquí.
    }

    /// Proporciona acceso al contexto principal para interactuar con la base de datos.
    /// Este contexto permite realizar operaciones CRUD en los datos almacenados.
    var context: NSManagedObjectContext {
        container.viewContext
    }

    /// Método para guardar cambios de forma segura en Core Data.
    /// Garantiza que los cambios realizados en el contexto principal se persistan en la base de datos.
    func saveContext() {
        let context = container.viewContext // Obtiene el contexto principal.
        
        // Verifica si hay cambios no guardados en el contexto.
        if context.hasChanges {
            do {
                try context.save() // Intenta guardar los cambios pendientes.
            } catch {
                // Manejo de errores durante el guardado.
                let nsError = error as NSError
                fatalError("Error al guardar el contexto: \(nsError), \(nsError.userInfo)") // Detiene la ejecución en caso de error grave.
            }
        }
    }
}
