//
//  TestEntityRelationships.swift
//  agendaescolaredai
//
//  Created by Juan Antonio Sánchez Carrillo on 23/11/24.
//

import XCTest
import CoreData
@testable import agendaescolaredai

final class TestEntityRelationships: XCTestCase {
    override func setUpWithError() throws {
        deleteAllData()
    }

    override func tearDownWithError() throws {
        deleteAllData()
    }

    func testCentroAulaRelationship() throws {
        let context = PersistenceController.shared.context
        print("\nInicio de la prueba: Relaciones entre Centro y Aula")

        // Crear centro
        let centro = Centro(context: context)
        centro.id = UUID()
        centro.nombre = "Centro Relación"
        centro.ubicacion = "Ubicación Relación"

        // Crear aula
        let aula = Aula(context: context)
        aula.id = UUID()
        aula.nombre = "Aula Relación"
        aula.centro = centro
        try context.save()
        print("\nCentro y Aula creados y asociados.")

        // Verificar asociación
        XCTAssertEqual(aula.centro?.nombre, "Centro Relación", "El aula debe estar asociada al centro correctamente.")
        print("\nPrueba completada: La relación entre Centro y Aula es correcta.")
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

