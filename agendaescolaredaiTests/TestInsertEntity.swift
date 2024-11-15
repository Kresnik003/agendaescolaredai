//
//  TestInsertEntity.swift
//  agendaescolaredai
//
//  Created by Juan Antonio Sánchez Carrillo on 23/11/24.
//

import XCTest
import CoreData
@testable import agendaescolaredai

final class TestInsertEntity: XCTestCase {
    override func setUpWithError() throws {
        // Limpia los datos antes de iniciar cada prueba
        deleteAllData()
    }

    override func tearDownWithError() throws {
        // Limpia los datos después de cada prueba
        deleteAllData()
    }

    func testInsertCentro() throws {
        let context = PersistenceController.shared.context
        print("\nInicio de la prueba: Insertar Centro")

        // Crear centro
        let centro = Centro(context: context)
        centro.id = UUID()
        centro.nombre = "Centro de Prueba"
        centro.ubicacion = "Ubicación de Prueba"
        print("\nCentro creado con ID: \(centro.id?.uuidString ?? "Sin ID")")

        // Guardar cambios
        try context.save()
        print("\nCentro guardado en la base de datos.")

        // Verificar inserción
        let fetchRequest: NSFetchRequest<Centro> = Centro.fetchRequest()
        let centros = try context.fetch(fetchRequest)
        XCTAssertEqual(centros.count, 1, "Debe haber un centro guardado.")
        XCTAssertEqual(centros.first?.nombre, "Centro de Prueba", "El nombre del centro debe coincidir.")
        print("\nPrueba completada: El centro se ha insertado correctamente.")
    }

    private func deleteAllData() {
        let context = PersistenceController.shared.context
        let model = context.persistentStoreCoordinator?.managedObjectModel

        model?.entities.forEach { entity in
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.name!)
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do {
                try context.execute(batchDeleteRequest)
            } catch {
                print("Error al eliminar la entidad \(entity.name ?? "Desconocida"): \(error.localizedDescription)")
            }
        }
    }
}
