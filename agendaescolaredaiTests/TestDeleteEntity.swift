//
//  TestDeleteEntity.swift
//  agendaescolaredai
//
//  Created by Juan Antonio Sánchez Carrillo on 23/11/24.
//

import XCTest
import CoreData
@testable import agendaescolaredai

final class TestDeleteEntity: XCTestCase {
    override func setUpWithError() throws {
        deleteAllData()
    }

    override func tearDownWithError() throws {
        deleteAllData()
    }

    func testDeleteCentro() throws {
        let context = PersistenceController.shared.context
        print("\nInicio de la prueba: Eliminar Centro")

        // Crear centro
        let centro = Centro(context: context)
        centro.id = UUID()
        centro.nombre = "Centro a Eliminar"
        centro.ubicacion = "Ubicación de Eliminar"
        try context.save()
        print("\nCentro creado y guardado en la base de datos.")

        // Eliminar centro
        context.delete(centro)
        try context.save()
        print("\nCentro eliminado de la base de datos.")

        // Verificar eliminación
        let fetchRequest: NSFetchRequest<Centro> = Centro.fetchRequest()
        let centros = try context.fetch(fetchRequest)
        XCTAssertEqual(centros.count, 0, "No debe haber centros en la base de datos.")
        print("\nPrueba completada: El centro se ha eliminado correctamente.")
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
