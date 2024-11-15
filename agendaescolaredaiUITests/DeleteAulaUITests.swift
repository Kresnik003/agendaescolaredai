//
//  DeleteAulaUITests.swift
//  agendaescolaredaiUITests
//
//  Created by Juan Antonio Sánchez Carrillo on 24/11/24.
//

import XCTest

final class DeleteAulaUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        // Configuración inicial antes de cada prueba.
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()

        // Monitor para manejar alertas inesperadas.
        addUIInterruptionMonitor(withDescription: "Handle Alert") { alert in
            if alert.buttons["OK"].exists {
                alert.buttons["OK"].tap()
                return true
            }
            return false
        }
    }

    override func tearDownWithError() throws {
        // Liberar recursos después de cada prueba.
        app = nil
    }

    func testDeleteAula() throws {
        // **Paso 1: Inicio de sesión**
        let emailField = app.textFields["emailTextField"]
        XCTAssertTrue(emailField.exists, "El campo de correo electrónico no existe.")
        emailField.tap()
        emailField.typeText("admin@edai.com")

        let passwordField = app.secureTextFields["passwordSecureField"]
        XCTAssertTrue(passwordField.exists, "El campo de contraseña no existe.")
        passwordField.tap()
        passwordField.typeText("admin123")

        let loginButton = app.buttons["loginButton"]
        XCTAssertTrue(loginButton.exists, "El botón de inicio de sesión no existe.")
        loginButton.tap()

        // **Paso 2: Navegar a la sección "Administrar Aulas"**
        let adminAulasOption = app.images["adminAulasOption"]
        XCTAssertTrue(adminAulasOption.waitForExistence(timeout: 5), "La opción 'Administrar Aulas' no existe.")
        adminAulasOption.tap()

        // **Paso 3: Selección y eliminación de un aula**
        let aulaCell = app.collectionViews.buttons["As Bolboretas, Centro: EDAI O ALTO, Rango de edad: 1-2 años, Alumnos: 24"]
        XCTAssertTrue(aulaCell.exists, "El aula 'As Bolboretas' no existe en la lista.")

        // Gesto de deslizamiento personalizado
        let startPoint = aulaCell.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)) // Punto inicial (lado derecho de la celda)
        let endPoint = aulaCell.coordinate(withNormalizedOffset: CGVector(dx: 0.1, dy: 0.5)) // Punto final (lado izquierdo)
        startPoint.press(forDuration: 0.2, thenDragTo: endPoint) // Presionar y arrastrar

        // **Paso 4: Verificar que el aula ha sido eliminada**
        XCTAssertFalse(aulaCell.exists, "El aula 'As Bolboretas' sigue presente después de eliminarla.")        
    }
}

