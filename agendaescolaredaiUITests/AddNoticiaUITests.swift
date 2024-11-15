//
//  AddNoticiaUITests.swift
//  agendaescolaredaiUITests
//
//  Created by Juan Antonio Sánchez Carrillo on 24/11/24.
//

import XCTest

final class AddNoticiaUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        // Configuración inicial antes de ejecutar cada test.
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()

        // Manejar alertas emergentes.
        addUIInterruptionMonitor(withDescription: "Handle Alert") { alert in
            if alert.buttons["OK"].exists {
                alert.buttons["OK"].tap()
                return true
            }
            return false
        }
    }

    override func tearDownWithError() throws {
        // Liberar recursos después de cada test.
        app = nil
    }

    func testAddNoticia() throws {
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

        // **Paso 2: Navegar a la sección "Noticias"**
        let adminNoticiasOptionCard = app.images["adminNoticiasOptionCard"]
        XCTAssertTrue(adminNoticiasOptionCard.waitForExistence(timeout: 5), "La opción 'Gestionar Noticias' no existe.")
        adminNoticiasOptionCard.tap()

        // **Paso 3: Añadir una noticia**
        let addNoticiaButton = app.buttons["addNoticiaBottomButton"]
        XCTAssertTrue(addNoticiaButton.waitForExistence(timeout: 5), "El botón 'Añadir Noticia' no existe.")
        addNoticiaButton.tap()

        // Llenar los datos de la noticia
        let tituloField = app.collectionViews.textFields["tituloTextField"]
        XCTAssertTrue(tituloField.exists, "El campo de título no existe.")
        tituloField.tap()
        tituloField.typeText("Prueba")

        let contenidoEditor = app.collectionViews.textViews["contenidoTextEditor"]
        XCTAssertTrue(contenidoEditor.exists, "El editor de contenido no existe.")
        contenidoEditor.tap()
        contenidoEditor.typeText("Prueba")

        // Guardar la noticia
        let guardarNoticiaButton = app.navigationBars["Nueva Noticia"].buttons["guardarNoticiaButton"]
        XCTAssertTrue(guardarNoticiaButton.exists, "El botón 'Guardar Noticia' no existe.")
        guardarNoticiaButton.tap()

        // **Paso 4: Verificar que la noticia se haya guardado**
        let noticiasView = app.collectionViews["adminNoticiasView"]
        XCTAssertTrue(noticiasView.waitForExistence(timeout: 10), "La vista de noticias no se cargó correctamente.")

        let noticiaGuardada = noticiasView.cells.buttons["Prueba, Publicado por: Administradora General, Prueba, Fecha: 29/11/2024"]
        XCTAssertTrue(noticiaGuardada.exists, "La nueva noticia no se encuentra en la lista.")
        noticiaGuardada.tap()
    }
}
