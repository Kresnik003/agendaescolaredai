//
//  EditUserUITests.swift
//  agendaescolaredaiUITests
//
//  Created by Juan Antonio Sánchez Carrillo on 23/11/24.
//

import XCTest

final class EditUserUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        // Configuración inicial antes de cada test.
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()

        // Manejar alertas emergentes inesperadas.
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

    func testEditUser() throws {
        let app = XCUIApplication()
        app.launch()

        // Paso 1: Inicio de sesión
        let emailField = app.textFields["emailTextField"]
        XCTAssertTrue(emailField.waitForExistence(timeout: 5), "El campo de correo electrónico no está visible.")
        emailField.tap()
        emailField.typeText("admin@edai.com")

        let passwordField = app.secureTextFields["passwordSecureField"]
        XCTAssertTrue(passwordField.exists, "El campo de contraseña no está visible.")
        passwordField.tap()
        passwordField.typeText("admin123")

        let loginButton = app.buttons["loginButton"]
        XCTAssertTrue(loginButton.exists, "El botón de inicio de sesión no está visible.")
        loginButton.tap()

        // Paso 2: Navegación
        let adminUsersOption = app.images["adminUsersOption"]
        XCTAssertTrue(adminUsersOption.waitForExistence(timeout: 5), "La opción 'Administrar Usuarios' no está visible.")
        adminUsersOption.tap()

        // Paso 3: Selección del usuario
        let collectionView = app.collectionViews["usersAndStudentsList"]
        XCTAssertTrue(collectionView.waitForExistence(timeout: 5), "La lista de usuarios y alumnos no está visible.")
        let userCell = collectionView.cells.element(boundBy: 2) // Cambiar el índice si es necesario.
        XCTAssertTrue(userCell.exists, "No se encontró la celda del usuario esperado.")
        userCell.tap()

        // Paso 4: Editar el nombre
        let editUserNameField = app.textFields["editUserNameField"]
        XCTAssertTrue(editUserNameField.waitForExistence(timeout: 5), "El campo para editar el nombre no está visible.")
        editUserNameField.tap()

        // Paso 5: Guardar cambios
        let saveButton = app.buttons["editUserSaveButton"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 5), "El botón de guardar no está visible.")
        saveButton.tap()

        // Confirmación opcional
        XCTAssertTrue(collectionView.exists, "Regresó correctamente a la lista de usuarios.")
    }
}
