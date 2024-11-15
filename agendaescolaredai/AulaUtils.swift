//
//  AulaUtils.swift
//  agendaescolaredai
//
//  Created by Juan Antonio Sánchez Carrillo on 20/11/24.
//

import SwiftUI
import CoreData

/// Función que asigna automáticamente un aula a un alumno según su edad, respetando el límite de capacidad del aula.
/// - Parameter alumno: El alumno al que se desea asignar un aula.
func autoAsignarAula(para alumno: Alumno) {
    // Obtiene el contexto compartido de Core Data.
    let context = PersistenceController.shared.context

    // Configura un `FetchRequest` para obtener todas las aulas ordenadas por edad mínima y luego por nombre.
    let fetchRequest: NSFetchRequest<Aula> = Aula.fetchRequest()
    fetchRequest.sortDescriptors = [
        NSSortDescriptor(keyPath: \Aula.edadMinima, ascending: true), // Ordena por edad mínima de forma ascendente.
        NSSortDescriptor(keyPath: \Aula.nombre, ascending: true) // Ordena alfabéticamente por nombre en caso de empate.
    ]

    do {
        // Obtiene todas las aulas desde la base de datos.
        let aulas = try context.fetch(fetchRequest)

        // Verifica que el alumno tenga una fecha de nacimiento asignada.
        guard let fechaNacimiento = alumno.fechaNacimiento else { return }

        // Calcula la edad del alumno en años a partir de su fecha de nacimiento.
        let edad = Calendar.current.dateComponents([.year], from: fechaNacimiento, to: Date()).year ?? 0

        // Busca la primera aula que cumpla con las condiciones:
        // - La edad del alumno está dentro del rango de edades permitido para el aula.
        // - El aula tiene espacio disponible (capacidad máxima no superada).
        if let aulaAsignada = aulas.first(where: {
            $0.edadMinima <= edad && $0.edadMaxima >= edad && // Verifica que la edad del alumno esté en el rango del aula.
            ($0.alumnos?.count ?? 0) < $0.capacidadMaxima // Verifica que el aula no esté llena.
        }) {
            // Asigna el aula encontrada al alumno.
            alumno.aula = aulaAsignada
            print("Alumno \(alumno.nombre ?? "Sin Nombre") asignado a aula \(aulaAsignada.nombre ?? "Sin Nombre").") // Mensaje de éxito.
        } else {
            // No se encontró un aula adecuada o con espacio disponible.
            print("No se encontró un aula adecuada o con espacio para el alumno \(alumno.nombre ?? "Sin Nombre").") // Mensaje de error.
        }
    } catch {
        // Manejo de errores en caso de fallo al obtener las aulas.
        print("Error al asignar aula: \(error.localizedDescription)") // Mensaje de error con descripción.
    }
}
