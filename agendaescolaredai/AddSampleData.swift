//
//  AddSampleData.swift
//  agendaescolaredai
//
//  Created by Juan Antonio Sánchez Carrillo on 16/11/24.
//

import Foundation
import CoreData
import UIKit

// MARK: - Borrar Todos los Datos
/// Función que elimina todas las entidades de la base de datos para realizar una limpieza completa.
func deleteAllData() {
    let context = PersistenceController.shared.context // Obtiene el contexto de Core Data
    let model = context.persistentStoreCoordinator?.managedObjectModel // Obtiene el modelo de datos

    // Itera sobre cada entidad definida en el modelo
    model?.entities.forEach { entity in
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.name!) // Solicitud de eliminación
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest) // Solicitud de eliminación masiva

        do {
            try context.execute(batchDeleteRequest) // Ejecuta la eliminación
            print("Eliminada la entidad: \(entity.name ?? "Desconocida")")
        } catch {
            print("Error al eliminar la entidad \(entity.name ?? "Desconocida"): \(error.localizedDescription)") // Error al eliminar
        }
    }
    print("\nBase de datos limpiada completamente.") // Mensaje final de limpieza
}

// MARK: - Población de la Base de Datos
/// Función para poblar la base de datos con datos iniciales.
func populateDatabase() {
    let context = PersistenceController.shared.context // Obtiene el contexto de Core Data

    deleteAllData() // Limpia todos los datos antes de poblar

    // Formateador de fechas
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd/MM/yyyy"
    
    print("\nIniciando la población de la base de datos...")
    
    // Inserción de un Centro
    print("\nInsertando centro...")
    let centro = Centro(context: context)
    centro.id = UUID()
    centro.nombre = "EDAI RIO DO POZO"
    centro.telefono = "881 934 028"
    centro.ubicacion = "Avda. Gonzalo Navarro, 1 - Narón 15570 (A Coruña)"
    centro.descripcion = "Centro de primer ciclo de Educación Infantil."
    
    let centro2 = Centro(context: context)
    centro2.id = UUID()
    centro2.nombre = "EDAI O ALTO"
    centro2.telefono = "881 936 079"
    centro2.ubicacion = "Garda, 2 P-6 Bajo - 15570 Narón (A Coruña)"
    centro2.descripcion = "Centro de primer ciclo de Educación Infantil."
    
    // Inserción de Usuarios
    print("\nInsertando usuarios...")
    let admin = Usuario(context: context)
    admin.id = UUID()
    admin.nombre = "Administradora General"
    admin.email = "admin@edai.com"
    admin.contrasena = "admin123"
    admin.rol = "administrador"
    
    let profesorGeneral = Usuario(context: context)
    profesorGeneral.id = UUID()
    profesorGeneral.nombre = "Profesora General"
    profesorGeneral.email = "profesora.general@edai.com"
    profesorGeneral.contrasena = "profesora123"
    profesorGeneral.rol = "profesor"

    let profesorTartarugas = Usuario(context: context)
    profesorTartarugas.id = UUID()
    profesorTartarugas.nombre = "Profesora Tartarugas"
    profesorTartarugas.email = "profesora.tartarugas@edai.com"
    profesorTartarugas.contrasena = "profesora123"
    profesorTartarugas.rol = "profesor"

    let profesorLeons = Usuario(context: context)
    profesorLeons.id = UUID()
    profesorLeons.nombre = "Profesora Leons"
    profesorLeons.email = "profesora.leons@edai.com"
    profesorLeons.contrasena = "profesora123"
    profesorLeons.rol = "profesor"

    let profesorOsos = Usuario(context: context)
    profesorOsos.id = UUID()
    profesorOsos.nombre = "Profesora Osos"
    profesorOsos.email = "profesora.osos@edai.com"
    profesorOsos.contrasena = "profesora123"
    profesorOsos.rol = "profesor"

    let profesorXirafas = Usuario(context: context)
    profesorXirafas.id = UUID()
    profesorXirafas.nombre = "Profesora Xirafas"
    profesorXirafas.email = "profesora.xirafas@edai.com"
    profesorXirafas.contrasena = "profesora123"
    profesorXirafas.rol = "profesor"
    
    let tutor = Usuario(context: context)
    tutor.id = UUID()
    tutor.nombre = "Tutora General"
    tutor.email = "tutora@edai.com"
    tutor.contrasena = "tutora123"
    tutor.rol = "tutor"
    
    let tutor1 = Usuario(context: context)
    tutor1.id = UUID()
    tutor1.nombre = "Juan Antonio Sánchez Carrillo"
    tutor1.email = "jasanchez@edai.com"
    tutor1.contrasena = "jasanchez123"
    tutor1.rol = "tutor"
    
    print("\nInsertando Alumno Emma...")
    let alumno1 = Alumno(context: context)
    alumno1.id = UUID()
    alumno1.nombre = "Emma Sánchez Nuñez"
    alumno1.centro = centro
    alumno1.tutor = tutor1
    alumno1.imagen = "Emma"
    alumno1.fechaNacimiento = dateFormatter.date(from: "27/08/2021")
    
    print("\nInsertando Alumno Abraham...")
    let alumno2 = Alumno(context: context)
    alumno2.id = UUID()
    alumno2.nombre = "Abraham Sánchez Nuñez"
    alumno2.centro = centro
    alumno2.tutor = tutor1
    alumno2.imagen = "Abraham"
    alumno2.fechaNacimiento = dateFormatter.date(from: "27/08/2022")
    
    print("\nInsertando Alumno Daniela...")
    let alumno3 = Alumno(context: context)
    alumno3.id = UUID()
    alumno3.nombre = "Daniela Sánchez Nuñez"
    alumno3.centro = centro
    alumno3.tutor = tutor1
    alumno3.imagen = "Daniela"
    alumno3.fechaNacimiento = dateFormatter.date(from: "27/08/2024")

    // Inserción de Aulas
    print("\nInsertando Aulas")
    let aulaTartatugas = Aula(context: context)
    aulaTartatugas.id = UUID()
    aulaTartatugas.nombre = "As Tartarugas"
    aulaTartatugas.curso = "2023/2024"
    aulaTartatugas.edadMinima = 0
    aulaTartatugas.edadMaxima = 1
    aulaTartatugas.capacidadMaxima = 25
    aulaTartatugas.imagen = "aulaTartarugas"
    aulaTartatugas.addToProfesores(profesorTartarugas)
    aulaTartatugas.addToProfesores(profesorGeneral)
    aulaTartatugas.addToProfesores(admin)
    aulaTartatugas.addToAlumnos(alumno3)
    aulaTartatugas.centro = centro

    let aulaTartatugas2 = Aula(context: context)
    aulaTartatugas2.id = UUID()
    aulaTartatugas2.nombre = "As Tartarugas"
    aulaTartatugas2.curso = "2023/2024"
    aulaTartatugas2.edadMinima = 0
    aulaTartatugas2.edadMaxima = 1
    aulaTartatugas2.capacidadMaxima = 25
    aulaTartatugas2.imagen = "aulaTartarugas2"
    aulaTartatugas2.addToProfesores(admin)
    aulaTartatugas2.centro = centro2
   
    let aulaLeons = Aula(context: context)
    aulaLeons.id = UUID()
    aulaLeons.nombre = "Os Leóns"
    aulaLeons.curso = "2023/2024"
    aulaLeons.edadMinima = 1
    aulaLeons.edadMaxima = 2
    aulaLeons.capacidadMaxima = 25
    aulaLeons.imagen = "aulaLeons"
    aulaLeons.addToProfesores(profesorLeons)
    aulaLeons.addToProfesores(profesorGeneral)
    aulaLeons.addToProfesores(admin)
    aulaLeons.addToAlumnos(alumno2)
    aulaLeons.centro = centro

    let aulaLeons2 = Aula(context: context)
    aulaLeons2.id = UUID()
    aulaLeons2.nombre = "Os Leóns"
    aulaLeons2.curso = "2023/2024"
    aulaLeons2.edadMinima = 1
    aulaLeons2.edadMaxima = 2
    aulaLeons2.capacidadMaxima = 25
    aulaLeons2.imagen = "aulaLeons2"
    aulaLeons2.addToProfesores(admin)
    aulaLeons2.centro = centro2
    
    let aulaBolboretas = Aula(context: context)
    aulaBolboretas.id = UUID()
    aulaBolboretas.nombre = "As Bolboretas"
    aulaBolboretas.curso = "2023/2024"
    aulaBolboretas.edadMinima = 1
    aulaBolboretas.edadMaxima = 2
    aulaBolboretas.capacidadMaxima = 25
    aulaBolboretas.imagen = "aulaBolboretas"
    aulaBolboretas.addToProfesores(admin)
    aulaBolboretas.centro = centro2
    
    let aulaXoaninas = Aula(context: context)
    aulaXoaninas.id = UUID()
    aulaXoaninas.nombre = "As Xoaniñas"
    aulaXoaninas.curso = "2023/2024"
    aulaXoaninas.edadMinima = 1
    aulaXoaninas.edadMaxima = 2
    aulaXoaninas.capacidadMaxima = 25
    aulaXoaninas.imagen = "aulaXoaninas"
    aulaXoaninas.addToProfesores(admin)
    aulaXoaninas.centro = centro2
        
    let aulaOsos = Aula(context: context)
    aulaOsos.id = UUID()
    aulaOsos.nombre = "Os Osos"
    aulaOsos.curso = "2023/2024"
    aulaOsos.edadMinima = 2
    aulaOsos.edadMaxima = 3
    aulaOsos.capacidadMaxima = 25
    aulaOsos.imagen = "aulaOsos"
    aulaOsos.addToProfesores(profesorOsos)
    aulaOsos.addToProfesores(profesorGeneral)
    aulaOsos.addToProfesores(admin)
    aulaOsos.centro = centro

    let aulaXirafas = Aula(context: context)
    aulaXirafas.id = UUID()
    aulaXirafas.nombre = "As Xirafas"
    aulaXirafas.curso = "2023/2024"
    aulaXirafas.edadMinima = 2
    aulaXirafas.edadMaxima = 3
    aulaXirafas.capacidadMaxima = 25
    aulaXirafas.imagen = "aulaXirafas"
    aulaXirafas.addToProfesores(profesorXirafas)
    aulaXirafas.addToProfesores(profesorGeneral)
    aulaXirafas.addToProfesores(admin)
    aulaXirafas.addToAlumnos(alumno1)
    aulaXirafas.centro = centro

    let aulaXirafas2 = Aula(context: context)
    aulaXirafas2.id = UUID()
    aulaXirafas2.nombre = "As Xirafas"
    aulaXirafas2.curso = "2023/2024"
    aulaXirafas2.edadMinima = 2
    aulaXirafas2.edadMaxima = 3
    aulaXirafas2.capacidadMaxima = 25
    aulaXirafas2.imagen = "aulaXirafas2"
    aulaXirafas2.addToProfesores(admin)
    aulaXirafas2.centro = centro2
    
    let aulaOurizos = Aula(context: context)
    aulaOurizos.id = UUID()
    aulaOurizos.nombre = "Os Ourizos"
    aulaOurizos.curso = "2023/2024"
    aulaOurizos.edadMinima = 2
    aulaOurizos.edadMaxima = 3
    aulaOurizos.capacidadMaxima = 25
    aulaOurizos.imagen = "aulaOurizos"
    aulaOurizos.addToProfesores(admin)
    aulaOurizos.centro = centro2
        
    // Asignar las aulas a una lista para iterar fácilmente
    let aulas = [aulaTartatugas, aulaLeons, aulaOsos, aulaXirafas, aulaOurizos, aulaXirafas2, aulaXoaninas, aulaBolboretas, aulaTartatugas2, aulaLeons2]

    // Crear alumnos de relleno y asignarlos a las aulas creadas
    print("\nCreando alumnos de relleno y asignándolos a las aulas creadas...")
    for aula in aulas {
        guard let edadMinima = Int(exactly: aula.edadMinima),
              let edadMaxima = Int(exactly: aula.edadMaxima),
              let centroAsignado = aula.centro else {
            print("Error: El aula \(aula.nombre ?? "Sin nombre") no tiene un centro asignado.")
            continue
        }

        for i in 1...24 { // Máximo 24 alumnos por aula
            let alumno = Alumno(context: context)
            alumno.id = UUID()
            alumno.nombre = "Alumno \(i) de \(aula.nombre ?? "Aula")"
            alumno.tutor = tutor
            alumno.aula = aula
            alumno.centro = centroAsignado // Asigna el centro del aula al alumno

            // Calcular fecha de nacimiento en función del rango de edad del aula
            let currentYear = Calendar.current.component(.year, from: Date())
            let yearOfBirth = currentYear - Int.random(in: edadMinima...edadMaxima)
            let randomDay = Int.random(in: 1...28)

            if let birthDate = dateFormatter.date(from: "\(randomDay)/01/\(yearOfBirth)") {
                alumno.fechaNacimiento = birthDate
            }
        }
    }

    // Guardar cambios en el contexto
    do {
        try context.save()
    } catch {
        print("Error al guardar los alumnos: \(error.localizedDescription)")
    }
   

    // Inserción de Noticias
    // Fecha base
    let calendar = Calendar.current
    let baseDate = Date()

    // Noticia 1
    let noticia1 = Noticia(context: context)
    noticia1.id = UUID()
    noticia1.titulo = "Nueva Actividad Escolar"
    noticia1.contenido = "Se realizará una excursión al parque el próximo viernes."
    noticia1.fechaPublicacion = calendar.date(byAdding: .weekOfYear, value: 0, to: baseDate)
    noticia1.autor = admin
    noticia1.centro = centro
    /*
    // Noticia 2
    let noticia2 = Noticia(context: context)
    noticia2.id = UUID()
    noticia2.titulo = "Reunión de Padres"
    noticia2.contenido = "La reunión de padres será el próximo lunes a las 18:00. Por favor, se ruega puntualidad."
    noticia2.fechaPublicacion = calendar.date(byAdding: .weekOfYear, value: 1, to: baseDate)
    noticia2.autor = admin
    noticia2.centro = nil

  
    // Noticia 3
    let noticia3 = Noticia(context: context)
    noticia3.id = UUID()
    noticia3.titulo = "Taller de Pintura"
    noticia3.contenido = "Los niños participarán en un taller de pintura el próximo martes. Necesitarán traer un delantal o ropa vieja."
    noticia3.fechaPublicacion = calendar.date(byAdding: .weekOfYear, value: 2, to: baseDate)
    noticia3.autor = admin
    noticia3.centro = nil
    
    // Noticia 4
    let noticia4 = Noticia(context: context)
    noticia4.id = UUID()
    noticia4.titulo = "Visita al Zoo"
    noticia4.contenido = "El viernes 1 de diciembre realizaremos una visita al zoo. Por favor, no olviden firmar la autorización antes del miércoles 29."
    noticia4.fechaPublicacion = calendar.date(byAdding: .weekOfYear, value: 3, to: baseDate)
    noticia4.autor = admin
    noticia4.centro = nil

    // Noticia 5
    let noticia5 = Noticia(context: context)
    noticia5.id = UUID()
    noticia5.titulo = "Día de la Fruta"
    noticia5.contenido = "¡El jueves celebramos el Día de la Fruta! Cada niño deberá traer una fruta para compartir. Habrá actividades divertidas sobre alimentación saludable."
    noticia5.fechaPublicacion = calendar.date(byAdding: .weekOfYear, value: 4, to: baseDate)
    noticia5.autor = admin
    noticia5.centro = nil

    // Noticia 6
    let noticia6 = Noticia(context: context)
    noticia6.id = UUID()
    noticia6.titulo = "Obra de Teatro Infantil"
    noticia6.contenido = "El próximo miércoles tendremos una obra de teatro titulada 'El Bosque Encantado'. La función comenzará a las 10:00 y durará aproximadamente una hora."
    noticia6.fechaPublicacion = calendar.date(byAdding: .weekOfYear, value: 5, to: baseDate)
    noticia6.autor = admin
    noticia6.centro = centro

    // Noticia 7
    let noticia7 = Noticia(context: context)
    noticia7.id = UUID()
    noticia7.titulo = "Nueva Normativa"
    noticia7.contenido = "Se informa a las familias que, debido a las nuevas regulaciones, el horario de entrada será estrictamente a las 9:00. Rogamos puntualidad."
    noticia7.fechaPublicacion = calendar.date(byAdding: .weekOfYear, value: 6, to: baseDate)
    noticia7.autor = admin
    noticia7.centro = nil

    // Noticia 8
    let noticia8 = Noticia(context: context)
    noticia8.id = UUID()
    noticia8.titulo = "Clases de Música"
    noticia8.contenido = "¡Aprenderemos música jugando! A partir de este mes, los niños tendrán clases de música todos los martes y jueves por la mañana."
    noticia8.fechaPublicacion = calendar.date(byAdding: .weekOfYear, value: 7, to: baseDate)
    noticia8.autor = admin
    noticia8.centro = centro

    // Noticia 9
    let noticia9 = Noticia(context: context)
    noticia9.id = UUID()
    noticia9.titulo = "Fiesta de Navidad"
    noticia9.contenido = """
    ¡La fiesta de Navidad está cerca!
    Los niños cantarán villancicos y realizarán pequeñas representaciones teatrales.
    Les pedimos que los pequeños traigan un disfraz relacionado con la Navidad para el día 20 de diciembre.
    """
    noticia9.fechaPublicacion = calendar.date(byAdding: .weekOfYear, value: 8, to: baseDate)
    noticia9.autor = admin
    noticia9.centro = nil

    // Noticia 10
    let noticia10 = Noticia(context: context)
    noticia10.id = UUID()
    noticia10.titulo = "Día de los Animales"
    noticia10.contenido = "El viernes los niños pueden traer un juguete relacionado con los animales para compartir en clase. ¡Jugaremos todos juntos!"
    noticia10.fechaPublicacion = calendar.date(byAdding: .weekOfYear, value: 9, to: baseDate)
    noticia10.autor = admin
    noticia10.centro = nil

    // Noticia 11
    let noticia11 = Noticia(context: context)
    noticia11.id = UUID()
    noticia11.titulo = "Cuenta cuentos"
    noticia11.contenido = """
    La semana que viene tendremos una actividad especial de cuenta cuentos con invitados que narrarán historias maravillosas.
    La actividad será el martes de 10:00 a 11:30 en el aula de usos múltiples.
    """
    noticia11.fechaPublicacion = calendar.date(byAdding: .weekOfYear, value: 10, to: baseDate)
    noticia11.autor = admin
    noticia11.centro = nil

    // Noticia 12
    let noticia12 = Noticia(context: context)
    noticia12.id = UUID()
    noticia12.titulo = "Juegos en el Patio"
    noticia12.contenido = "El próximo viernes los niños disfrutarán de una jornada especial de juegos en el patio. Por favor, asegúrense de que lleven ropa cómoda."
    noticia12.fechaPublicacion = calendar.date(byAdding: .weekOfYear, value: 11, to: baseDate)
    noticia12.autor = admin
    noticia12.centro = centro
    */
    
    // Inserción de Menús Mensuales
    print("\nInsertando menús para el mes actual...")
    let today = Date()
    if let range = Calendar.current.range(of: .day, in: .month, for: today) {
        for day in range {
            if let date = Calendar.current.date(from: DateComponents(year: Calendar.current.component(.year, from: today),month: Calendar.current.component(.month, from: today),day: day)) {
                let menu = Menu(context: context)
                menu.id = UUID()
                menu.fecha = date
                menu.desayuno = [
                    "Leche", "Batido", "Zumo de frutas",
                    "Tostadas con mermelada", "Cereales integrales",
                    "Bizcocho casero", "Pan con tomate y aceite de oliva",
                    "Porridge con frutas", "Croissant integral",
                    "Pan con mantequilla y miel", "Tostadas con queso fresco",
                    "Smoothie de frutas", "Magdalenas caseras",
                    "Crema de cacao casera con pan integral", "Tortitas de avena con plátano"
                ].randomElement()!

                menu.tentempie = [
                    "Fruta", "Galletas integrales", "Barrita de cereales",
                    "Palitos de zanahoria con hummus", "Mini bocadillo de queso",
                    "Yogur bebible", "Crackers integrales con queso fresco",
                    "Manzana o pera troceada", "Frutos secos (sin sal y aptos para niños)",
                    "Trocitos de plátano seco", "Mini wrap de pavo",
                    "Tomatitos cherry", "Bocadillo de crema de cacahuete natural",
                    "Rollitos de jamón y queso", "Gajos de naranja"
                ].randomElement()!

                menu.primerPlato = [
                    "Puré de verduras", "Sopa de fideos", "Ensalada de pasta",
                    "Crema de calabaza", "Arroz con verduras",
                    "Ensalada de arroz con huevo duro", "Guiso de lentejas suave",
                    "Macarrones con tomate natural y queso rallado",
                    "Puré de zanahoria y patata", "Sopa de pollo con fideos",
                    "Arroz a la cubana", "Cuscús con verduras",
                    "Puré de guisantes", "Gazpacho suave",
                    "Caldo de verduras con arroz"
                ].randomElement()!

                menu.segundoPlato = [
                    "Pollo al horno", "Pescado a la plancha", "Albóndigas de carne",
                    "Tortilla de patatas", "Hamburguesa de pollo o pavo casera",
                    "Merluza rebozada al horno", "Croquetas de pescado o pollo",
                    "Revuelto de huevo con espinacas", "Filete de cerdo a la plancha",
                    "Empanadillas caseras de atún", "Pollo empanado al horno",
                    "Lomo de salmón al vapor", "Brochetas de pollo y verduras",
                    "Estofado de ternera suave", "Huevos rellenos de atún"
                ].randomElement()!

                menu.postre = [
                    "Yogur natural", "Fruta fresca", "Natillas caseras",
                    "Flan de huevo", "Compota de manzana",
                    "Brochetas de frutas variadas", "Gelatina de frutas sin azúcar añadido",
                    "Batido de plátano con leche", "Macedonia de frutas",
                    "Tarta de queso al horno", "Brownie saludable de chocolate",
                    "Pudding de chía con frutas", "Manzana al horno",
                    "Mini magdalena de zanahoria", "Batido de fresas con yogur"
                ].randomElement()!
            }
        }
    }

    // Inserción de Registros Diarios
    print("\nAñadiendo registros diarios variados a cada alumno...")
    do {
        let alumnos = try context.fetch(Alumno.fetchRequest()) as! [Alumno]
        for alumno in alumnos {
            for i in 0..<20 {
                let registro = RegistroDiario(context: context)
                registro.id = UUID()
                registro.fecha = Calendar.current.date(byAdding: .day, value: -i, to: Date())
                registro.alumno = alumno
                registro.desayuno = Bool.random()
                registro.tentempie = Bool.random()
                registro.primerPlato = Bool.random()
                registro.segundoPlato = Bool.random()
                registro.postre = Bool.random()
                registro.toallitasRestantes = Int16.random(in: 0...100)
                registro.panalesRestantes = Int16.random(in: 0...100)
            }
        }
    } catch {
        print("Error al recuperar los alumnos: \(error.localizedDescription)")
    }

    
    func addSampleFotos(context: NSManagedObjectContext, profesor: Usuario) {
        let sampleImages = [
            "foto1.jpg",
            "foto2.jpg",
            "foto3.jpg",
            "foto4.jpg"
        ]
        
        for imageName in sampleImages {
            guard let imageData = UIImage(named: imageName)?.jpegData(compressionQuality: 1.0) else {
                print("No se pudo cargar la imagen \(imageName)")
                continue
            }
            
            let nuevaFoto = Foto(context: context)
            nuevaFoto.id = UUID()
            nuevaFoto.fecha = Date()
            nuevaFoto.imagen = imageData
            nuevaFoto.profesor = profesor
        }
        
        do {
            try context.save()
            print("Fotos de ejemplo añadidas correctamente.")
        } catch {
            print("Error al guardar las fotos: \(error.localizedDescription)")
        }
    }

    addSampleFotos(context: context, profesor: profesorGeneral)

    
    
    // Guardado de Datos
    do {
        print("\nGuardando los datos...")
        try context.save()
        print("\nDatos guardados exitosamente.")
    } catch {
        print("Error al guardar los datos: \(error.localizedDescription)")
    }

    printAllData()
}

// MARK: - Impresión de Todos los Datos
/// Función para imprimir todos los datos en la base de datos.
func printAllData() {
    let context = PersistenceController.shared.context

    print("\nObteniendo todos los datos...")

    let usuarioRequest: NSFetchRequest<Usuario> = Usuario.fetchRequest()
    let aulaRequest: NSFetchRequest<Aula> = Aula.fetchRequest()
    let alumnoRequest: NSFetchRequest<Alumno> = Alumno.fetchRequest()
    let registroRequest: NSFetchRequest<RegistroDiario> = RegistroDiario.fetchRequest()
    let menuRequest: NSFetchRequest<Menu> = Menu.fetchRequest()

    do {
        let usuarios = try context.fetch(usuarioRequest)
        print("\nUsuarios:")
        for usuario in usuarios {
            print("""
            
            Nombre: \(usuario.nombre ?? "Sin nombre")
            Rol: \(usuario.rol ?? "Sin rol")
            Correo: \(usuario.email ?? "Sin correo")
            Contraseña: \(usuario.contrasena ?? "Sin contraseña")
            
            """)
        }

        let aulas = try context.fetch(aulaRequest)
        print("\nAulas:")
        for aula in aulas {
            print("""
            
            Nombre: \(aula.nombre ?? "Sin nombre")
            Curso: \(aula.curso ?? "Sin curso")
            Profesores: \((aula.profesores?.allObjects as? [Usuario])?.map { $0.nombre ?? "Sin nombre" }.joined(separator: ", ") ?? "Sin profesores")
            Centro: \(aula.centro?.nombre ?? "Sin centro")
            
            """)
        }

        let alumnos = try context.fetch(alumnoRequest)
        print("\nAlumnos:")
        for alumno in alumnos {
            print("""
            
            Nombre: \(alumno.nombre ?? "Sin nombre")
            Fecha de Nacimiento: \(alumno.fechaNacimiento ?? Date())
            Tutor: \(alumno.tutor?.nombre ?? "Sin tutor")
            Aula: \(alumno.aula?.nombre ?? "Sin aula")
            Centro: \(alumno.centro?.nombre ?? "Sin centro")
            
            """)
        }

        let registros = try context.fetch(registroRequest)
        print("\nRegistros Diarios:")
        for registro in registros {
            print("""
            
            Alumno: \(registro.alumno?.nombre ?? "Sin alumno")
            Fecha: \(registro.fecha ?? Date())
            Desayuno: \(registro.desayuno ? "Sí" : "No")
            Tentempié: \(registro.tentempie ? "Sí" : "No")
            Primer Plato: \(registro.primerPlato ? "Sí" : "No")
            Segundo Plato: \(registro.segundoPlato ? "Sí" : "No")
            Postre: \(registro.postre ? "Sí" : "No")
            Toallitas Restantes: \(registro.toallitasRestantes)%
            Pañales Restantes: \(registro.panalesRestantes)%
            
            """)
        }

        let menus = try context.fetch(menuRequest)
        print("\nMenús:")
        for menu in menus {
            print("""
            
            Fecha: \(menu.fecha ?? Date())
            Desayuno: \(menu.desayuno ?? "Sin información")
            Tentempié: \(menu.tentempie ?? "Sin información")
            Primer Plato: \(menu.primerPlato ?? "Sin información")
            Segundo Plato: \(menu.segundoPlato ?? "Sin información")
            Postre: \(menu.postre ?? "Sin información")
            
            """)
        }
    } catch {
        print("Error al obtener los datos: \(error.localizedDescription)")
    }
}
