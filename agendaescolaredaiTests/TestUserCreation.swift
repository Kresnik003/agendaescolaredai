//
//  TestUserCreation.swift
//  agendaescolaredai
//
//  Created by Juan Antonio Sánchez Carrillo on 23/11/24.
//

import XCTest
import CoreData
@testable import agendaescolaredai

final class TestUserCreation: XCTestCase {
    override func setUpWithError() throws {
        deleteAllData()
    }

    override func tearDownWithError() throws {
        deleteAllData()
    }

    func testCreateUser() throws {
        let context = PersistenceController.shared.context
        print("\nInicio de la prueba: Crear Usuario")

        // Crear usuario
        let usuario = Usuario(context: context)
        usuario.id = UUID()
        usuario.nombre = "Usuario Prueba"
        usuario.email = "usuario@prueba.com"
        usuario.contrasena = "password123"
        usuario.rol = "tutor"
        try context.save()
        print("Usuario creado y guardado en la base de datos.")

        // Verificar creación
        let fetchRequest: NSFetchRequest<Usuario> = Usuario.fetchRequest()
        let usuarios = try context.fetch(fetchRequest)
        XCTAssertEqual(usuarios.count, 1, "Debe haber un usuario guardado.")
        XCTAssertEqual(usuarios.first?.email, "usuario@prueba.com", "El email del usuario debe coincidir.")
        print("\nPrueba completada: El usuario se ha creado correctamente.")
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
